import 'package:kynos/core/errors/failures.dart';
import 'package:kynos/domain/entities/gamification/character_class.dart';
import 'package:kynos/domain/entities/gamification/character_stats.dart';
import 'package:kynos/domain/entities/gamification/runner_character.dart';
import 'package:kynos/domain/entities/health_summary.dart';
import 'package:kynos/domain/repositories/health_repository.dart';

class AssignCharacterClassUseCase {
  const AssignCharacterClassUseCase({required HealthRepository healthRepository})
      : _healthRepository = healthRepository;

  final HealthRepository _healthRepository;

  Future<({RunnerCharacter? character, Failure? failure})> call() async {
    final result = await _healthRepository.getSummaries(days: 14);
    if (result.failure != null) {
      return (character: null, failure: result.failure);
    }

    final summaries = result.summaries;
    final characterClass = _assignClass(summaries);
    final stats = _buildInitialStats(summaries);

    final character = RunnerCharacter(
      characterClass: characterClass,
      level: 1,
      xp: 0,
      stats: stats,
      earnedTitles: const [],
      activeTitle: null,
      createdAt: DateTime.now(),
      lastUpdated: DateTime.now(),
    );

    return (character: character, failure: null);
  }

  CharacterClass _assignClass(List<HealthSummary> summaries) {
    if (summaries.isEmpty) return const Apex();

    final withCadence =
        summaries.where((s) => s.cadenceSpm != null).toList();
    final withHrv = summaries.where((s) => s.hrvMs != null).toList();
    final withPower =
        summaries.where((s) => s.runningPowerWatts != null).toList();

    final avgCadence = withCadence.isEmpty
        ? 0.0
        : withCadence.map((s) => s.cadenceSpm!).reduce((a, b) => a + b) /
            withCadence.length;

    // HRV consistency: low variance → Sage
    double hrvVariance = 999;
    if (withHrv.length > 2) {
      final mean = withHrv.map((s) => s.hrvMs!).reduce((a, b) => a + b) /
          withHrv.length;
      hrvVariance = withHrv
              .map((s) => (s.hrvMs! - mean) * (s.hrvMs! - mean))
              .reduce((a, b) => a + b) /
          withHrv.length;
    }

    final totalRunKm = summaries.fold<double>(
        0, (sum, s) => sum + ((s.runningWorkoutDistanceMeters ?? 0) / 1000));
    final avgWeeklyKm = (totalRunKm / summaries.length) * 7;

    final avgPower = withPower.isEmpty
        ? 0.0
        : withPower
                .map((s) => s.runningPowerWatts!)
                .reduce((a, b) => a + b) /
            withPower.length;

    final scores = <String, double>{
      'phantom': avgCadence > 170 ? 2.0 : avgCadence > 160 ? 1.0 : 0.0,
      'iron': avgWeeklyKm > 50 ? 2.0 : avgWeeklyKm > 30 ? 1.0 : 0.0,
      'surge': avgPower > 250 ? 2.0 : avgPower > 180 ? 1.0 : 0.0,
      'sage':
          withHrv.length >= 5 && hrvVariance < 100 ? 2.0 : withHrv.length >= 3 ? 1.0 : 0.0,
    };

    final maxScore = scores.values.reduce((a, b) => a > b ? a : b);
    if (maxScore < 1.0) return const Apex();

    final winner =
        scores.entries.where((e) => e.value == maxScore).first.key;
    return CharacterClass.fromId(winner);
  }

  CharacterStats _buildInitialStats(List<HealthSummary> summaries) {
    if (summaries.isEmpty) return const CharacterStats();

    final withHrv = summaries.where((s) => s.hrvMs != null).toList();
    final withCadence =
        summaries.where((s) => s.cadenceSpm != null).toList();
    final withPower =
        summaries.where((s) => s.runningPowerWatts != null).toList();
    final withSleep =
        summaries.where((s) => s.sleepHours != null).toList();

    final avgHrv = withHrv.isEmpty
        ? 40.0
        : withHrv.map((s) => s.hrvMs!).reduce((a, b) => a + b) /
            withHrv.length;
    final avgCadence = withCadence.isEmpty
        ? 160.0
        : withCadence.map((s) => s.cadenceSpm!).reduce((a, b) => a + b) /
            withCadence.length;
    final avgPower = withPower.isEmpty
        ? 150.0
        : withPower
                .map((s) => s.runningPowerWatts!)
                .reduce((a, b) => a + b) /
            withPower.length;
    final avgSleep = withSleep.isEmpty
        ? 7.0
        : withSleep.map((s) => s.sleepHours!).reduce((a, b) => a + b) /
            withSleep.length;

    final totalKm = summaries.fold<double>(
        0, (sum, s) => sum + ((s.runningWorkoutDistanceMeters ?? 0) / 1000));

    // Map data ranges to 10–40 starter stat range (room to grow to 100).
    final strength =
        (((avgPower - 100) / 200) * 30 + 10).clamp(10.0, 40.0).round();
    final endurance =
        ((totalKm / (14 * 5)) * 30 + 10).clamp(10.0, 40.0).round();
    final speed =
        (((avgCadence - 150) / 40) * 30 + 10).clamp(10.0, 40.0).round();
    final form =
        (((avgCadence - 150) / 40) * 25 + 10).clamp(10.0, 35.0).round();
    final recovery =
        (((avgHrv - 20) / 80) * 30 + 10).clamp(10.0, 40.0).round();
    final willpower =
        ((avgSleep / 9) * 20 + 10).clamp(10.0, 30.0).round();

    return CharacterStats(
      strength: strength,
      endurance: endurance,
      speed: speed,
      form: form,
      recovery: recovery,
      willpower: willpower,
    );
  }
}
