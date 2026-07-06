import 'package:flutter_test/flutter_test.dart';
import 'package:kynos/core/constants/imported_workout_ids.dart';
import 'package:kynos/domain/entities/health_summary.dart';
import 'package:kynos/domain/entities/workout_session.dart';
import 'package:kynos/domain/entities/workout_route_point.dart';
import 'package:kynos/domain/repositories/imported_health_persistence.dart';
import 'package:kynos/domain/usecases/health/import_workout_usecase.dart';

void main() {
  group('ImportWorkoutUseCase', () {
    late _FakeImportedHealthPersistence store;
    late ImportWorkoutUseCase useCase;

    setUp(() {
      store = _FakeImportedHealthPersistence();
      useCase = ImportWorkoutUseCase(store);
    });

    WorkoutSession validSession() {
      return WorkoutSession(
        id: ImportedWorkoutIds.generate(),
        start: DateTime(2026, 4, 20, 7),
        end: DateTime(2026, 4, 20, 7, 45),
        workoutType: 'running',
        distanceMeters: 5000,
        sourceName: 'Manual entry',
      );
    }

    test('persists a valid workout', () async {
      final session = validSession();

      final result = await useCase(
        workout: session,
        now: DateTime(2026, 4, 21),
      );

      expect(result.failure, isNull);
      expect(result.workout, session);
      expect(await store.workoutCount(), 1);
    });

    test('rejects future workouts', () async {
      final session = WorkoutSession(
        id: ImportedWorkoutIds.generate(),
        start: DateTime(2026, 5, 1),
        end: DateTime(2026, 5, 1, 1),
        workoutType: 'running',
        distanceMeters: 3000,
        sourceName: 'Manual entry',
      );

      final result = await useCase(
        workout: session,
        now: DateTime(2026, 4, 21),
      );

      expect(result.workout, isNull);
      expect(result.failure, isNotNull);
    });

    test('rejects zero distance', () async {
      final session = WorkoutSession(
        id: ImportedWorkoutIds.generate(),
        start: DateTime(2026, 4, 20, 7),
        end: DateTime(2026, 4, 20, 7, 30),
        workoutType: 'running',
        distanceMeters: 0,
        sourceName: 'Manual entry',
      );

      final result = await useCase(
        workout: session,
        now: DateTime(2026, 4, 21),
      );

      expect(result.workout, isNull);
      expect(result.failure, isNotNull);
    });
  });
}

class _FakeImportedHealthPersistence implements ImportedHealthPersistence {
  final workouts = <WorkoutSession>[];

  @override
  Future<void> clearAll() async => workouts.clear();

  @override
  Future<List<HealthSummary>> getSummaries({
    required DateTime since,
  }) async =>
      [];

  @override
  Future<List<WorkoutRoutePoint>> getRoutePoints(String workoutId) async => [];

  @override
  Future<List<WorkoutSession>> getWorkouts({
    required DateTime since,
    int? limit,
  }) async =>
      workouts;

  @override
  Future<void> saveSummaries(List<HealthSummary> summaries) async {}

  @override
  Future<void> saveWorkout({
    required WorkoutSession workout,
    List<WorkoutRoutePoint> routePoints = const [],
  }) async => workouts.add(workout);

  @override
  Future<int> workoutCount() async => workouts.length;
}
