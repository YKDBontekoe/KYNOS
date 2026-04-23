import 'package:kynos/core/errors/failures.dart';
import 'package:kynos/core/utils/readiness_score.dart';
import 'package:kynos/domain/entities/health_summary.dart';
import 'package:kynos/domain/entities/insights/insight_confidence.dart';
import 'package:kynos/domain/entities/insights/today_insights.dart';
import 'package:kynos/domain/repositories/ai_coach_repository.dart';
import 'package:kynos/domain/repositories/ai_model_repository.dart';
import 'package:kynos/domain/repositories/health_repository.dart';
import 'package:kynos/shared/utils/llm_output_parser.dart';

class GenerateTodayInsightsUseCase {
  const GenerateTodayInsightsUseCase({
    required HealthRepository healthRepository,
    required AiCoachRepository aiCoachRepository,
    required AiModelRepository aiModelRepository,
  }) : _healthRepository = healthRepository,
       _aiCoachRepository = aiCoachRepository,
       _aiModelRepository = aiModelRepository;

  final HealthRepository _healthRepository;
  final AiCoachRepository _aiCoachRepository;
  final AiModelRepository _aiModelRepository;

  Future<({TodayInsights? insights, Failure? failure, bool usedModel})>
  call() async {
    final todayResult = await _healthRepository.getToday();
    if (todayResult.failure != null) {
      return (insights: null, failure: todayResult.failure, usedModel: false);
    }

    final today = todayResult.summary;
    if (today == null) {
      return (
        insights: null,
        failure: const HealthDataFailure('No health summary for today.'),
        usedModel: false,
      );
    }

    final historyResult = await _healthRepository.getSummaries(days: 14);
    if (historyResult.failure != null) {
      return (insights: null, failure: historyResult.failure, usedModel: false);
    }

    final sortedHistory = historyResult.summaries.toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    final yesterday = _findYesterday(sortedHistory, today.date);

    final base = _buildDeterministic(today: today, yesterday: yesterday);
    final refined = await _tryRefineWithModel(
      baseline: base,
      today: today,
      yesterday: yesterday,
      history: sortedHistory,
    );

    return (
      insights: refined ?? base,
      failure: null,
      usedModel: refined != null,
    );
  }

  HealthSummary? _findYesterday(
    List<HealthSummary> history,
    DateTime todayDate,
  ) {
    final dayStart = DateTime(todayDate.year, todayDate.month, todayDate.day);
    final yesterdayStart = dayStart.subtract(const Duration(days: 1));
    for (final sample in history.reversed) {
      final sampleDay = DateTime(
        sample.date.year,
        sample.date.month,
        sample.date.day,
      );
      if (sampleDay == yesterdayStart) return sample;
    }
    return null;
  }

  TodayInsights _buildDeterministic({
    required HealthSummary today,
    required HealthSummary? yesterday,
  }) {
    // Pessimistic defaults: missing data → worse readiness for "today" insight.
    final readiness = ReadinessScore.compute(
      today,
      fallbackHrvMs: 20,
      fallbackRhrBpm: 75,
      fallbackSleepHours: 5,
      fallbackBloodOxygenPercent: 95,
    );

    final whatChanged = <String>[
      ..._deltaLine(
        label: 'Recovery (HRV)',
        today: today.hrvMs,
        yesterday: yesterday?.hrvMs,
        unit: 'ms',
        higherIsBetter: true,
      ),
      ..._deltaLine(
        label: 'Resting pulse',
        today: today.rhrBpm,
        yesterday: yesterday?.rhrBpm,
        unit: 'bpm',
        higherIsBetter: false,
      ),
      ..._deltaLine(
        label: 'Sleep',
        today: today.sleepHours,
        yesterday: yesterday?.sleepHours,
        unit: 'h',
        higherIsBetter: true,
        digits: 1,
      ),
    ];

    final riskFlags = <String>[];
    if ((today.sleepHours ?? 0) < 6) {
      riskFlags.add('Sleep debt: keep intensity lower today.');
    }
    if ((today.hrvMs ?? 0) < 35) {
      riskFlags.add('Low recovery score (HRV): strain is elevated.');
    }
    if ((today.rhrBpm ?? 999) > 70) {
      riskFlags.add('High resting pulse: possible fatigue signal.');
    }
    if (readiness < 45) {
      riskFlags.add('Low readiness: overreaching risk is higher.');
    }
    if (riskFlags.isEmpty) {
      riskFlags.add('No strong risk signal today.');
    }

    final actionNow = readiness >= 70
        ? 'Run quality as planned. Start controlled.'
        : readiness >= 50
        ? 'Keep it aerobic. Cap effort at RPE 6-7.'
        : 'Switch to easy run or brisk walk. Cut volume ~20%.';

    final actionTonight = (today.sleepHours ?? 0) < 7
        ? 'Wind down early. Target 8+ hours in bed.'
        : 'Hydrate and hit protein to support tomorrow.';

    final evidence = <String>[
      if (today.hrvMs != null) 'Recovery ${today.hrvMs!.round()} ms',
      if (today.rhrBpm != null) 'Resting pulse ${today.rhrBpm!.round()} bpm',
      if (today.sleepHours != null)
        'Sleep ${today.sleepHours!.toStringAsFixed(1)} h',
      if (today.runningWorkoutDistanceMeters != null)
        'Run ${(today.runningWorkoutDistanceMeters! / 1000).toStringAsFixed(2)} km',
      if (today.steps != null) 'Steps ${today.steps}',
    ];

    final confidence = _confidenceForToday(today);

    return TodayInsights(
      readinessBrief: _readinessSummary(readiness),
      whatChanged: whatChanged.take(3).toList(),
      riskFlags: riskFlags.take(3).toList(),
      actionNow: actionNow,
      actionTonight: actionTonight,
      evidence: evidence.take(4).toList(),
      confidence: confidence,
    );
  }

  List<String> _deltaLine({
    required String label,
    required double? today,
    required double? yesterday,
    required String unit,
    required bool higherIsBetter,
    int digits = 0,
  }) {
    if (today == null || yesterday == null) return const [];
    final delta = today - yesterday;
    if (delta.abs() < 0.001) return const [];

    final improved = higherIsBetter ? delta > 0 : delta < 0;
    final trend = improved
        ? 'improved'
        : delta > 0
        ? 'increased'
        : 'decreased';
    final sign = delta > 0 ? '+' : '';
    final todayLabel = digits == 0
        ? today.round().toString()
        : today.toStringAsFixed(digits);
    final deltaLabel = digits == 0
        ? delta.round().toString()
        : delta.toStringAsFixed(digits);
    return [
      '$label $trend to $todayLabel $unit ($sign$deltaLabel vs yesterday).',
    ];
  }

  InsightConfidence _confidenceForToday(HealthSummary today) {
    var available = 0;
    if (today.hrvMs != null) available++;
    if (today.rhrBpm != null) available++;
    if (today.sleepHours != null) available++;
    if (today.bloodOxygenPercent != null) available++;

    if (available >= 4) return InsightConfidence.high;
    if (available >= 2) return InsightConfidence.medium;
    return InsightConfidence.low;
  }

  String _readinessSummary(double score) {
    if (score >= 80) return 'Great readiness. Good day for quality work.';
    if (score >= 65) return 'Solid readiness. Tempo or aerobic work fits.';
    if (score >= 45) return 'Moderate readiness. Keep effort controlled.';
    return 'Low readiness. Prioritise recovery and easy movement.';
  }

  Future<TodayInsights?> _tryRefineWithModel({
    required TodayInsights baseline,
    required HealthSummary today,
    required HealthSummary? yesterday,
    required List<HealthSummary> history,
  }) async {
    try {
      await _aiModelRepository.initialize();
      if (!_aiModelRepository.hasActiveModel) return null;

      final contextLines = <String>[
        'Today HRV: ${today.hrvMs?.toStringAsFixed(1) ?? 'na'}',
        'Today RHR: ${today.rhrBpm?.toStringAsFixed(1) ?? 'na'}',
        'Today sleep: ${today.sleepHours?.toStringAsFixed(1) ?? 'na'}',
        'Today SpO2: ${today.bloodOxygenPercent?.toStringAsFixed(1) ?? 'na'}',
        'Yesterday HRV: ${yesterday?.hrvMs?.toStringAsFixed(1) ?? 'na'}',
        '14d records: ${history.length}',
      ];

      final prompt = StringBuffer()
        ..writeln('Task: refine concise daily training insight text.')
        ..writeln(
          'Model size is small: avoid complex reasoning and keep outputs short.',
        )
        ..writeln(
          'Use only provided context and baseline insight. Do not invent data.',
        )
        ..writeln('Return EXACTLY these keys, one per line:')
        ..writeln('READINESS_BRIEF: ...')
        ..writeln('ACTION_NOW: ...')
        ..writeln('ACTION_TONIGHT: ...')
        ..writeln('CHANGED: item1 | item2 | item3')
        ..writeln('RISKS: item1 | item2 | item3')
        ..writeln('')
        ..writeln('Context:')
        ..writeln(contextLines.join('\n'))
        ..writeln('')
        ..writeln('Baseline:')
        ..writeln('READINESS_BRIEF: ${baseline.readinessBrief}')
        ..writeln('ACTION_NOW: ${baseline.actionNow}')
        ..writeln('ACTION_TONIGHT: ${baseline.actionTonight}')
        ..writeln('CHANGED: ${baseline.whatChanged.join(' | ')}')
        ..writeln('RISKS: ${baseline.riskFlags.join(' | ')}');

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
        readinessBrief: parsed.readinessBrief,
        actionNow: parsed.actionNow,
        actionTonight: parsed.actionTonight,
        whatChanged: parsed.changed,
        riskFlags: parsed.risks,
      );
    } catch (_) {
      return null;
    }
  }

  ({
    String readinessBrief,
    String actionNow,
    String actionTonight,
    List<String> changed,
    List<String> risks,
  })?
  _parseModelText(String raw) {
    final readinessBrief = LlmOutputParser.take(raw, 'READINESS_BRIEF');
    final actionNow = LlmOutputParser.take(raw, 'ACTION_NOW');
    final actionTonight = LlmOutputParser.take(raw, 'ACTION_TONIGHT');

    if (readinessBrief == null || actionNow == null || actionTonight == null) {
      return null;
    }

    return (
      readinessBrief: readinessBrief,
      actionNow: actionNow,
      actionTonight: actionTonight,
      changed: LlmOutputParser.splitList(LlmOutputParser.take(raw, 'CHANGED')),
      risks: LlmOutputParser.splitList(LlmOutputParser.take(raw, 'RISKS')),
    );
  }
}
