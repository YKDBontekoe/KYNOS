import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kynos/core/constants/imported_workout_ids.dart';
import 'package:kynos/domain/entities/workout_session.dart';
import 'package:kynos/domain/usecases/health/import_workout_usecase.dart';
import 'package:kynos/infrastructure/health/drift_imported_health_store.dart';
import 'package:kynos/infrastructure/health/imported_health_database.dart';
import 'package:kynos/infrastructure/health/imported_health_store.dart';

void main() {
  group('ImportWorkoutUseCase', () {
    late ImportedHealthDatabase db;
    late ImportedHealthStore store;
    late ImportWorkoutUseCase useCase;

    setUp(() {
      db = ImportedHealthDatabase(NativeDatabase.memory());
      store = DriftImportedHealthStore(db);
      useCase = ImportWorkoutUseCase(store);
    });

    tearDown(() async {
      await db.close();
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
