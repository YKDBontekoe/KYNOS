import 'package:kynos/domain/entities/gamification/character_class.dart';
import 'package:kynos/domain/entities/gamification/character_stats.dart';
import 'package:kynos/domain/entities/gamification/runner_character.dart';
import 'package:kynos/domain/entities/gamification/xp_gain.dart';
import 'package:kynos/domain/entities/health_summary.dart';
import 'package:kynos/domain/entities/workout_session.dart';

class ComputeXpUseCase {
  const ComputeXpUseCase();

  XpGain call({
    required WorkoutSession session,
    required RunnerCharacter character,
    HealthSummary? sameDaySummary,
  }) {
    final distanceKm = (session.distanceMeters ?? 0) / 1000;
    final durationMin = session.duration.inMinutes.toDouble();

    // Base XP from volume
    final baseXp = (distanceKm * 12 + durationMin * 1.5).round();

    // Readiness multiplier — running on low readiness earns Willpower bonus
    final readiness = _readiness(sameDaySummary);
    final readinessMultiplier = readiness < 40
        ? 1.6
        : readiness < 60
            ? 1.2
            : 1.0;

    // Class signatory bonus
    final classMultiplier = switch (character.characterClass) {
      Surge() => 1.1,
      _ => 1.0,
    };

    final totalXp =
        (baseXp * readinessMultiplier * classMultiplier).round().clamp(5, 2000);

    final deltas = _computeStatDeltas(
      distanceKm: distanceKm,
      durationMin: durationMin,
      readiness: readiness,
      summary: sameDaySummary,
    );

    return XpGain(
      amount: totalXp,
      source: 'run_completed',
      earnedAt: session.end,
      statDeltas: deltas,
    );
  }

  double _readiness(HealthSummary? summary) {
    if (summary == null) return 60;
    final hrvScore = ((summary.hrvMs ?? 40).clamp(20, 110) - 20) / 90;
    final rhrScore =
        1 - (((summary.rhrBpm ?? 65).clamp(45, 90) - 45) / 45);
    final sleepScore =
        ((summary.sleepHours ?? 7).clamp(4, 9) - 4) / 5;
    final spo2Score =
        ((summary.bloodOxygenPercent ?? 97).clamp(90, 100) - 90) / 10;
    return ((hrvScore * 0.35 +
                rhrScore * 0.25 +
                sleepScore * 0.25 +
                spo2Score * 0.15) *
            100)
        .clamp(0, 100);
  }

  Map<CharacterStatId, int> _computeStatDeltas({
    required double distanceKm,
    required double durationMin,
    required double readiness,
    HealthSummary? summary,
  }) {
    final deltas = <CharacterStatId, int>{};

    // Endurance: long runs
    if (distanceKm > 5) {
      deltas[CharacterStatId.endurance] =
          (distanceKm / 5).floor().clamp(1, 4);
    }

    // Strength: power output or solid distance
    if ((summary?.runningPowerWatts ?? 0) > 200) {
      deltas[CharacterStatId.strength] = 2;
    } else if (distanceKm > 3) {
      deltas[CharacterStatId.strength] = 1;
    }

    // Form: cadence in the optimal 170–185 spm window
    final cadence = summary?.cadenceSpm ?? 0;
    if (cadence >= 170 && cadence <= 185) {
      deltas[CharacterStatId.form] = 3;
    } else if (cadence >= 160) {
      deltas[CharacterStatId.form] = 1;
    }

    // Speed: fast paced shorter runs
    if (distanceKm > 1 && durationMin > 0) {
      final paceMin = durationMin / distanceKm;
      if (paceMin < 5.5) {
        deltas[CharacterStatId.speed] = 2;
      } else if (paceMin < 6.5) {
        deltas[CharacterStatId.speed] = 1;
      }
    }

    // Recovery: running well-rested
    if ((summary?.sleepHours ?? 0) >= 7.5) {
      deltas[CharacterStatId.recovery] = 1;
    }

    // Willpower: running when body says no
    if (readiness < 50) {
      deltas[CharacterStatId.willpower] = 2;
    }

    return deltas;
  }
}
