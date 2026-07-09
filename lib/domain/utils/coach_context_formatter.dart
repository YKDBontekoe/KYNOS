import 'package:kynos/domain/entities/cloud_data_level.dart';
import 'package:kynos/domain/entities/coach/coach_context.dart';
import 'package:kynos/domain/entities/coach/coach_seed_topic.dart';
import 'package:kynos/domain/entities/workout_session.dart';
import 'package:kynos/domain/utils/gemma_device_capability.dart';
import 'package:kynos/domain/utils/gemma_inference_limits.dart';
import 'package:kynos/domain/utils/health_context_formatter.dart';

/// Formats [CoachContext] into a privacy-safe LLM prompt block.
abstract final class CoachContextFormatter {
  static const int _maxOnDeviceChars = GemmaInferenceLimits.maxPromptCharacters;

  static String formatForPrompt(
    CoachContext context, {
    CloudDataLevel cloudLevel = CloudDataLevel.full,
    GemmaInferenceTier tier = GemmaInferenceTier.full,
  }) {
    final isCloud =
        cloudLevel != CloudDataLevel.minimal || tier == GemmaInferenceTier.full;
    final level = isCloud ? cloudLevel : _tierToCloudLevel(tier);
    final sections = <String>[];

    sections.add(
      'Readiness: ${context.readinessScore.round()}/100 — ${context.readinessSummary}',
    );

    if (context.acwr != null && context.acwrRiskLabel != null) {
      sections.add(
        'ACWR: ${context.acwr!.toStringAsFixed(2)} — ${context.acwrRiskLabel}',
      );
    }

    final brief = context.dailyBrief;
    if (brief != null &&
        (context.readinessScore > 0 || context.healthHistory.isNotEmpty)) {
      sections.add(
        'Daily decision: ${brief.recommendation} (${brief.confidence} confidence, '
        '${brief.dataQuality} data)\nEvidence: ${brief.evidence.join('; ')}',
      );
    }

    final healthLines = HealthContextFormatter.summarizeForPrompt(
      context.healthHistory,
      level: level,
    );
    if (healthLines.isNotEmpty) {
      sections.add('Health metrics:\n${healthLines.join('\n')}');
    }

    final runLines = _formatRuns(context.recentRuns);
    if (runLines.isNotEmpty) {
      sections.add('Recent runs:\n${runLines.join('\n')}');
    }

    if (level != CloudDataLevel.minimal) {
      final profile = context.athleteProfile;
      if (profile != null) {
        sections.add(
          'Athlete preferences: goal ${profile.goal}, experience ${profile.experience}',
        );
      }
      final checkIn = context.morningCheckIn;
      if (checkIn != null) {
        sections.add(
          'Morning check-in: fatigue ${checkIn.fatigue}/10, '
          'soreness ${checkIn.soreness}/10, motivation ${checkIn.motivation}/10',
        );
      }
      final momentum = context.weeklyMomentum;
      if (momentum != null) {
        sections.add(
          'Weekly goal: ${momentum.thisWeekDistanceKm.toStringAsFixed(1)} / '
          '${momentum.distanceGoalKm.toStringAsFixed(0)} km '
          '(${(momentum.distanceGoalProgress * 100).round()}%)',
        );
      }

      final character = context.character;
      if (character != null) {
        final weakest = character.stats.weakest;
        sections.add(
          'Character: ${character.characterClass.name} Lv${character.level}, '
          'weakest stat ${weakest.fullName}',
        );
      }

      final insights = context.todayInsights;
      if (insights != null) {
        sections.add('Today insight: ${insights.readinessBrief}');
        if (insights.actionNow.isNotEmpty) {
          sections.add('Suggested action now: ${insights.actionNow}');
        }
      }
    }

    if (level == CloudDataLevel.full) {
      final training = context.trainingInsights;
      if (training != null) {
        sections.add('Training intent: ${training.sessionIntent}');
        if (training.adjustmentHints.isNotEmpty) {
          sections.add(
            'Adjustments:\n${training.adjustmentHints.map((h) => '- $h').join('\n')}',
          );
        }
      }

      if (context.isGaitCalibrated) {
        final c = context.gaitCoefficients;
        sections.add(
          'Gait model: β₀=${c.b0?.toStringAsFixed(3)}, '
          'β₁=${c.b1?.toStringAsFixed(4)}, β₂=${c.b2?.toStringAsFixed(4)}',
        );
      }

      for (final quest in context.activeQuests) {
        sections.add('Active quest: ${quest.title} — ${quest.objective}');
      }

      final debrief = context.postRunDebriefSummary;
      if (debrief != null && debrief.isNotEmpty) {
        sections.add('Recent post-run debrief: $debrief');
      }
    }

    if (context.seedTopic != CoachSeedTopic.general) {
      sections.add('Coach entry topic: ${context.seedTopic.name}');
    }

    var block = sections.join('\n\n');
    if (block.length > _maxOnDeviceChars) {
      block = block.substring(0, _maxOnDeviceChars);
    }
    return block;
  }

  static CloudDataLevel _tierToCloudLevel(GemmaInferenceTier tier) =>
      switch (tier) {
        GemmaInferenceTier.full => CloudDataLevel.full,
        GemmaInferenceTier.constrained => CloudDataLevel.standard,
        GemmaInferenceTier.disabled => CloudDataLevel.minimal,
      };

  static List<String> _formatRuns(List<WorkoutSession> runs) {
    return runs.map((run) {
      final date = '${run.start.month}/${run.start.day}';
      final parts = <String>[date, run.workoutType];
      if (run.distanceMeters != null && run.distanceMeters! > 0) {
        parts.add('${(run.distanceMeters! / 1000).toStringAsFixed(1)}km');
      }
      final mins = run.duration.inMinutes;
      if (mins > 0) {
        parts.add('${mins}min');
        if (run.distanceMeters != null && run.distanceMeters! > 0) {
          final paceMinPerKm = mins / (run.distanceMeters! / 1000);
          parts.add('${paceMinPerKm.toStringAsFixed(1)} min/km');
        }
      }
      if (run.energyKcal != null) {
        parts.add('${run.energyKcal!.round()} kcal');
      }
      return parts.join(', ');
    }).toList();
  }

  /// Assert-friendly check: formatted output must not contain GPS coordinates.
  static bool containsNoGpsLeakage(String formatted) {
    const forbidden = [
      'latitude',
      'longitude',
      'startLatitude',
      'startLongitude',
      'route',
      'GPS',
    ];
    final lower = formatted.toLowerCase();
    return !forbidden.any(lower.contains);
  }
}
