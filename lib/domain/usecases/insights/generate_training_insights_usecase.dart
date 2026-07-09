import 'package:kynos/core/errors/failures.dart';
import 'package:kynos/domain/entities/health_summary.dart';
import 'package:kynos/domain/entities/insights/insight_confidence.dart';
import 'package:kynos/domain/entities/insights/training_insights.dart';
import 'package:kynos/domain/entities/workout_session.dart';
import 'package:kynos/domain/repositories/ai_coach_repository.dart';
import 'package:kynos/domain/repositories/ai_model_repository.dart';
import 'package:kynos/domain/repositories/health_repository.dart';
import 'package:kynos/domain/utils/pace_format.dart';
import 'package:kynos/domain/utils/running_distance.dart';

class GenerateTrainingInsightsUseCase {
  const GenerateTrainingInsightsUseCase({
    required HealthRepository healthRepository,
    required AiCoachRepository aiCoachRepository,
    required AiModelRepository aiModelRepository,
  }) : _healthRepository = healthRepository,
       _aiCoachRepository = aiCoachRepository,
       _aiModelRepository = aiModelRepository;

  final HealthRepository _healthRepository;
  final AiCoachRepository _aiCoachRepository;
  final AiModelRepository _aiModelRepository;

  Future<({TrainingInsights? insights, Failure? failure, bool usedModel})>
  call() async {
    final historyResult = await _healthRepository.getSummaries(days: 30);
    if (historyResult.failure != null) {
      return (insights: null, failure: historyResult.failure, usedModel: false);
    }

    final runsResult = await _healthRepository.getRecentRuns(
      days: 30,
      limit: 40,
    );
    if (runsResult.failure != null) {
      return (insights: null, failure: runsResult.failure, usedModel: false);
    }

    final todayResult = await _healthRepository.getToday();
    if (todayResult.failure != null) {
      return (insights: null, failure: todayResult.failure, usedModel: false);
    }

    final history = historyResult.summaries.toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    final runs = runsResult.runs.toList()
      ..sort((a, b) => b.start.compareTo(a.start));

    final base = _buildDeterministic(
      history: history,
      runs: runs,
      today: todayResult.summary,
    );

    final refined = await _tryRefineWithModel(
      baseline: base,
      history: history,
      runs: runs,
      today: todayResult.summary,
    );

    return (
      insights: refined ?? base,
      failure: null,
      usedModel: refined != null,
    );
  }

  TrainingInsights _buildDeterministic({
    required List<HealthSummary> history,
    required List<WorkoutSession> runs,
    required HealthSummary? today,
  }) {
    final now = DateTime.now();
    final weekCutoff = now.subtract(const Duration(days: 7));
    final prevWeekCutoff = now.subtract(const Duration(days: 14));

    final thisWeekDistanceKm = history
        .where((s) => s.date.isAfter(weekCutoff))
        .map(dailyRunningDistanceKm)
        .fold(0.0, (a, b) => a + b);

    final prevWeekDistanceKm = history
        .where(
          (s) => s.date.isAfter(prevWeekCutoff) && s.date.isBefore(weekCutoff),
        )
        .map(dailyRunningDistanceKm)
        .fold(0.0, (a, b) => a + b);

    final distanceChangePct = prevWeekDistanceKm <= 0
        ? 0.0
        : ((thisWeekDistanceKm - prevWeekDistanceKm) / prevWeekDistanceKm) *
              100;

    final recoveryState = _recoveryState(today);
    final targetRpe = switch (recoveryState) {
      InsightConfidence.high => '7-8',
      InsightConfidence.medium => '6-7',
      InsightConfidence.low => '4-6',
    };

    final sessionIntent =
        'Intent: ${_intentLabel(recoveryState)}. '
        'Target RPE $targetRpe and keep the first half controlled.';

    final adjustmentHints = <String>[
      if (distanceChangePct > 15)
        'Volume is up ${distanceChangePct.round()}%: cut one accessory block if legs feel heavy.',
      if ((today?.sleepHours ?? 8) < 6.5)
        'Sleep is low: add 30-60s extra recovery between reps.',
      if ((today?.hrvMs ?? 50) < 35)
        'Recovery score (HRV) is low: drop one interval set if form fades.',
      if (runs.isNotEmpty)
        'If pace drifts >5% after halfway, finish easy aerobic.',
    ];

    if (adjustmentHints.isEmpty) {
      adjustmentHints.add('No major red flags. Run plan as normal.');
    }

    final postSessionDebrief = _buildDebrief(
      runs,
      thisWeekDistanceKm,
      distanceChangePct,
    );

    final evidence = <String>[
      '7d distance ${thisWeekDistanceKm.toStringAsFixed(1)} km',
      if (prevWeekDistanceKm > 0)
        'vs prior week ${prevWeekDistanceKm.toStringAsFixed(1)} km',
      if (today?.sleepHours != null)
        'Sleep ${today!.sleepHours!.toStringAsFixed(1)} h',
      if (today?.hrvMs != null) 'Recovery ${today!.hrvMs!.round()} ms',
      if (runs.isNotEmpty) 'Recent runs ${runs.take(3).length} sessions',
    ];

    return TrainingInsights(
      sessionIntent: sessionIntent,
      adjustmentHints: adjustmentHints.take(3).toList(),
      postSessionDebrief: postSessionDebrief.take(3).toList(),
      evidence: evidence.take(4).toList(),
      confidence: recoveryState,
    );
  }

  String _intentLabel(InsightConfidence confidence) {
    switch (confidence) {
      case InsightConfidence.high:
        return 'quality day';
      case InsightConfidence.medium:
        return 'controlled development day';
      case InsightConfidence.low:
        return 'recovery-biased day';
    }
  }

  InsightConfidence _recoveryState(HealthSummary? today) {
    if (today == null) return InsightConfidence.low;
    var score = 0;
    if ((today.sleepHours ?? 0) >= 7) score++;
    if ((today.hrvMs ?? 0) >= 45) score++;
    if ((today.rhrBpm ?? 99) <= 60) score++;

    if (score >= 3) return InsightConfidence.high;
    if (score >= 2) return InsightConfidence.medium;
    return InsightConfidence.low;
  }

  List<String> _buildDebrief(
    List<WorkoutSession> runs,
    double thisWeekDistanceKm,
    double distanceChangePct,
  ) {
    if (runs.isEmpty) {
      return const [
        'No recent run file found; complete one session to unlock debrief trends.',
      ];
    }

    final latest = runs.first;
    final latestDistance = latest.distanceMeters == null
        ? null
        : latest.distanceMeters! / 1000;
    final latestPace = formatPaceFromSession(
      duration: latest.duration,
      distanceMeters: latest.distanceMeters,
    );

    return [
      if (latestDistance != null && latestPace != null)
        'Latest run: ${latestDistance.toStringAsFixed(2)} km at $latestPace pace.',
      'Weekly load is ${thisWeekDistanceKm.toStringAsFixed(1)} km (${distanceChangePct >= 0 ? '+' : ''}${distanceChangePct.toStringAsFixed(0)}%).',
      'Next tweak: keep first 10 minutes easier before quality work.',
    ];
  }

  Future<TrainingInsights?> _tryRefineWithModel({
    required TrainingInsights baseline,
    required List<HealthSummary> history,
    required List<WorkoutSession> runs,
    required HealthSummary? today,
  }) async {
    try {
      final initResult = await _aiModelRepository.initialize();
      if (initResult.failure != null || !_aiModelRepository.hasActiveModel) {
        return null;
      }

      final context = <String>[
        'history_points=${history.length}',
        'runs_30d=${runs.length}',
        'today_sleep=${today?.sleepHours?.toStringAsFixed(1) ?? 'na'}',
        'today_hrv=${today?.hrvMs?.toStringAsFixed(1) ?? 'na'}',
      ];

      final prompt = StringBuffer()
        ..writeln(
          'Task: refine concise training insights for a small local model scenario.',
        )
        ..writeln('Keep each line short and concrete. Avoid abstractions.')
        ..writeln(
          'Use only context and baseline text below. Do not invent metrics.',
        )
        ..writeln('Return EXACTLY:')
        ..writeln('SESSION_INTENT: ...')
        ..writeln('ADJUSTMENTS: item1 | item2 | item3')
        ..writeln('DEBRIEF: item1 | item2 | item3')
        ..writeln('')
        ..writeln('Context:')
        ..writeln(context.join('\n'))
        ..writeln('')
        ..writeln('Baseline:')
        ..writeln('SESSION_INTENT: ${baseline.sessionIntent}')
        ..writeln('ADJUSTMENTS: ${baseline.adjustmentHints.join(' | ')}')
        ..writeln('DEBRIEF: ${baseline.postSessionDebrief.join(' | ')}');

      await _aiCoachRepository.resetSession();
      final buffer = StringBuffer();
      await for (final chunk in _aiCoachRepository.chat(
        userMessage: prompt.toString(),
      )) {
        buffer.write(chunk);
      }

      final parsed = _parseModelText(buffer.toString());
      if (parsed == null) return null;

      return baseline.copyWith(
        sessionIntent: parsed.sessionIntent,
        adjustmentHints: parsed.adjustments,
        postSessionDebrief: parsed.debrief,
      );
    } catch (_) {
      return null;
    }
  }

  ({String sessionIntent, List<String> adjustments, List<String> debrief})?
  _parseModelText(String raw) {
    String? take(String key) {
      final match = RegExp('$key\\s*:(.*)', multiLine: true).firstMatch(raw);
      return match?.group(1)?.trim();
    }

    List<String> splitList(String? value) {
      if (value == null || value.isEmpty) return const [];
      return value
          .split('|')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .take(3)
          .toList();
    }

    final sessionIntent = take('SESSION_INTENT');
    if (sessionIntent == null || sessionIntent.isEmpty) {
      return null;
    }

    return (
      sessionIntent: sessionIntent,
      adjustments: splitList(take('ADJUSTMENTS')),
      debrief: splitList(take('DEBRIEF')),
    );
  }
}
