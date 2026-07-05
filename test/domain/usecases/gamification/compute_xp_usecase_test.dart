import 'package:flutter_test/flutter_test.dart';
import 'package:kynos/domain/entities/gamification/character_class.dart';
import 'package:kynos/domain/entities/gamification/character_stats.dart';
import 'package:kynos/domain/entities/gamification/runner_character.dart';
import 'package:kynos/domain/entities/health_summary.dart';
import 'package:kynos/domain/entities/workout_session.dart';
import 'package:kynos/domain/usecases/gamification/compute_xp_usecase.dart';

void main() {
  group('ComputeXpUseCase', () {
    const useCase = ComputeXpUseCase();

    final character = RunnerCharacter(
      characterClass: const Surge(),
      level: 1,
      xp: 0,
      stats: const CharacterStats(),
      earnedTitles: const [],
      activeTitle: null,
      createdAt: DateTime(2026, 1, 1),
      lastUpdated: DateTime(2026, 1, 1),
    );

    test('awards base XP for a completed run', () {
      final session = WorkoutSession(
        id: 'run-1',
        start: DateTime(2026, 4, 20, 7),
        end: DateTime(2026, 4, 20, 7, 45),
        workoutType: 'running',
        distanceMeters: 8000,
        sourceName: 'HealthKit',
      );

      final gain = useCase(
        session: session,
        character: character,
      );

      expect(gain.amount, greaterThan(0));
      expect(gain.source, 'run_completed');
    });

    test('boosts XP when readiness is low (willpower bonus)', () {
      final session = WorkoutSession(
        id: 'run-2',
        start: DateTime(2026, 4, 20, 7),
        end: DateTime(2026, 4, 20, 7, 30),
        workoutType: 'running',
        distanceMeters: 5000,
        sourceName: 'HealthKit',
      );

      final lowReadiness = HealthSummary(
        date: DateTime(2026, 4, 20),
        hrvMs: 25,
        rhrBpm: 80,
        sleepHours: 4.5,
      );

      final normalGain = useCase(session: session, character: character);
      final lowReadinessGain = useCase(
        session: session,
        character: character,
        sameDaySummary: lowReadiness,
      );

      expect(lowReadinessGain.amount, greaterThan(normalGain.amount));
      expect(
        lowReadinessGain.statDeltas?[CharacterStatId.willpower],
        greaterThan(0),
      );
    });
  });
}
