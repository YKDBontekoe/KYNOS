import 'package:kynos/core/errors/failures.dart';
import 'package:kynos/domain/entities/workout_route_point.dart';
import 'package:kynos/domain/entities/workout_session.dart';
import 'package:kynos/infrastructure/health/imported_health_store.dart';

/// Validates and persists an imported workout to local storage.
class ImportWorkoutUseCase {
  const ImportWorkoutUseCase(this._store);

  final ImportedHealthStore _store;

  Future<({WorkoutSession? workout, Failure? failure})> call({
    required WorkoutSession workout,
    List<WorkoutRoutePoint> routePoints = const [],
    DateTime? now,
  }) async {
    final clock = now ?? DateTime.now();

    if (!workout.end.isAfter(workout.start)) {
      return (
        workout: null,
        failure: const HealthDataFailure('End time must be after start time'),
      );
    }

    if (workout.start.isAfter(clock)) {
      return (
        workout: null,
        failure: const HealthDataFailure('Workout cannot be in the future'),
      );
    }

    final distance = workout.distanceMeters ?? 0;
    if (distance <= 0) {
      return (
        workout: null,
        failure: const HealthDataFailure('Distance must be greater than zero'),
      );
    }

    try {
      await _store.saveWorkout(workout: workout, routePoints: routePoints);
      return (workout: workout, failure: null);
    } catch (e) {
      return (workout: null, failure: StorageFailure(e.toString()));
    }
  }
}
