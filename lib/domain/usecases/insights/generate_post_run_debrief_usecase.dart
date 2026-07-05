import 'package:kynos/domain/entities/ai_task_kind.dart';
import 'package:kynos/domain/entities/health_summary.dart';
import 'package:kynos/domain/entities/workout_session.dart';
import 'package:kynos/domain/repositories/ai_coach_repository.dart';
import 'package:kynos/domain/utils/readiness_score.dart';

/// Deterministic post-run debrief with optional LLM refinement.
class PostRunDebrief {
  const PostRunDebrief({
    required this.highlight,
    required this.oneFix,
    required this.recoveryNote,
    required this.usedModel,
  });

  final String highlight;
  final String oneFix;
  final String recoveryNote;
  final bool usedModel;
}

class GeneratePostRunDebriefUseCase {
  const GeneratePostRunDebriefUseCase({required this.aiCoach});

  final AiCoachRepository aiCoach;

  Future<PostRunDebrief> call({
    required WorkoutSession session,
    HealthSummary? sameDaySummary,
  }) async {
    final distanceKm = (session.distanceMeters ?? 0) / 1000;
    final durationMin = session.duration.inMinutes;
    final paceMin = distanceKm > 0 ? durationMin / distanceKm : 0.0;
    final readiness = readinessScoreOrDefault(sameDaySummary);

    final baseline = PostRunDebrief(
      highlight: distanceKm > 0
          ? 'Completed ${distanceKm.toStringAsFixed(1)} km in $durationMin min.'
          : 'Completed a $durationMin min session.',
      oneFix: paceMin > 0 && paceMin < 5.5
          ? 'Strong pace — add 10 min easy cooldown.'
          : 'Focus on cadence in the 170–180 spm range next run.',
      recoveryNote: readiness < 50
          ? 'Readiness is low — prioritise sleep tonight.'
          : 'Hydrate and walk 10 min to aid recovery.',
      usedModel: false,
    );

    if (!aiCoach.isReady) return baseline;

    final prompt = StringBuffer()
      ..writeln('Task: refine a post-run debrief.')
      ..writeln('Output keys only: HIGHLIGHT, ONE_FIX, RECOVERY_NOTE')
      ..writeln('Max 15 words per field. Do not invent metrics.')
      ..writeln('Context:')
      ..writeln('distance_km=${distanceKm.toStringAsFixed(1)}')
      ..writeln('duration_min=$durationMin')
      ..writeln('pace_min_per_km=${paceMin.toStringAsFixed(1)}')
      ..writeln('readiness=${readiness.round()}')
      ..writeln('Baseline:')
      ..writeln('HIGHLIGHT: ${baseline.highlight}')
      ..writeln('ONE_FIX: ${baseline.oneFix}')
      ..writeln('RECOVERY_NOTE: ${baseline.recoveryNote}');

    try {
      await aiCoach.resetSession();
      final buffer = StringBuffer();
      await for (final chunk in aiCoach.chat(
        userMessage: prompt.toString(),
        taskKind: AiTaskKind.runDebrief,
      )) {
        buffer.write(chunk);
      }

      final text = buffer.toString();
      return PostRunDebrief(
        highlight: _extract(text, 'HIGHLIGHT') ?? baseline.highlight,
        oneFix: _extract(text, 'ONE_FIX') ?? baseline.oneFix,
        recoveryNote: _extract(text, 'RECOVERY_NOTE') ?? baseline.recoveryNote,
        usedModel: true,
      );
    } on Object {
      return baseline;
    }
  }

  String? _extract(String text, String key) {
    final pattern = RegExp('$key:\\s*(.+)', caseSensitive: false);
    final match = pattern.firstMatch(text);
    return match?.group(1)?.trim();
  }
}
