import 'package:flutter_test/flutter_test.dart';
import 'package:kynos/core/errors/failures.dart';
import 'package:kynos/domain/entities/gamification/character_class.dart';
import 'package:kynos/domain/entities/health_summary.dart';
import 'package:kynos/domain/entities/workout_route_point.dart';
import 'package:kynos/domain/entities/workout_session.dart';
import 'package:kynos/domain/repositories/health_repository.dart';
import 'package:kynos/domain/usecases/gamification/assign_character_class_usecase.dart';

void main() {
  group('AssignCharacterClassUseCase', () {
    test('assigns Apex when no health history exists', () async {
      final useCase = AssignCharacterClassUseCase(
        healthRepository: _FakeHealthRepository(summaries: const []),
      );

      final result = await useCase();

      expect(result.failure, isNull);
      expect(result.character, isNotNull);
      expect(result.character!.characterClass, isA<Apex>());
    });

    test('assigns Phantom for high cadence runners', () async {
      final summaries = List.generate(
        7,
        (i) => HealthSummary(
          date: DateTime(2026, 4, i + 1),
          cadenceSpm: 175,
          runningWorkoutDistanceMeters: 10000,
        ),
      );

      final useCase = AssignCharacterClassUseCase(
        healthRepository: _FakeHealthRepository(summaries: summaries),
      );

      final result = await useCase();

      expect(result.failure, isNull);
      expect(result.character!.characterClass, isA<Phantom>());
    });
  });
}

class _FakeHealthRepository implements HealthRepository {
  _FakeHealthRepository({required this.summaries});

  final List<HealthSummary> summaries;

  @override
  Future<({List<HealthSummary> summaries, Failure? failure})> getSummaries({
    required int days,
  }) async =>
      (summaries: summaries, failure: null);

  @override
  Future<({HealthSummary? summary, Failure? failure})> getToday() async =>
      (summary: null, failure: null);

  @override
  Future<({List<WorkoutSession> runs, Failure? failure})> getRecentRuns({
    required int days,
    int limit = 20,
  }) async =>
      (runs: const <WorkoutSession>[], failure: null);

  @override
  Future<({List<WorkoutRoutePoint> points, Failure? failure})> getRunRoute({
    required String workoutUuid,
  }) async =>
      (points: const <WorkoutRoutePoint>[], failure: null);

  @override
  Future<bool> requestPermissions() async => true;

  @override
  Future<bool> hasPermissions() async => true;

  @override
  Future<({WorkoutSession? workout, Failure? failure})> getWorkoutById({
    required String workoutId,
  }) async =>
      (workout: null, failure: null);
}
