import 'package:kynos/core/constants/imported_workout_ids.dart';
import 'package:kynos/core/errors/failures.dart';
import 'package:kynos/domain/entities/health_summary.dart';
import 'package:kynos/domain/entities/workout_route_point.dart';
import 'package:kynos/domain/entities/workout_session.dart';
import 'package:kynos/domain/repositories/health_repository.dart';
import 'package:kynos/infrastructure/health/imported_health_store.dart';
import 'package:kynos/infrastructure/health/imported_workout_summary_aggregator.dart';

/// [HealthRepository] backed by locally imported workout data.
class ImportedHealthRepository implements HealthRepository {
  ImportedHealthRepository(this._store);

  final ImportedHealthStore _store;

  @override
  Future<bool> requestPermissions() async => false;

  @override
  Future<({List<HealthSummary> summaries, Failure? failure})> getSummaries({
    required int days,
  }) async {
    try {
      final since = DateTime.now().subtract(Duration(days: days));
      final workouts = await _store.getWorkouts(since: since);
      return (
        summaries: deriveSummariesFromWorkouts(workouts),
        failure: null,
      );
    } catch (e) {
      return (
        summaries: const <HealthSummary>[],
        failure: StorageFailure(e.toString()),
      );
    }
  }

  @override
  Future<({List<WorkoutSession> runs, Failure? failure})> getRecentRuns({
    required int days,
    int limit = 30,
  }) async {
    try {
      final since = DateTime.now().subtract(Duration(days: days));
      final runs = await _store.getWorkouts(since: since, limit: limit);
      return (runs: runs, failure: null);
    } catch (e) {
      return (
        runs: const <WorkoutSession>[],
        failure: StorageFailure(e.toString()),
      );
    }
  }

  @override
  Future<({List<WorkoutRoutePoint> points, Failure? failure})> getRunRoute({
    required String workoutUuid,
  }) async {
    if (!ImportedWorkoutIds.isImported(workoutUuid)) {
      return (
        points: const <WorkoutRoutePoint>[],
        failure: const HealthDataFailure('Not an imported workout'),
      );
    }

    try {
      final points = await _store.getRoutePoints(workoutUuid);
      return (points: points, failure: null);
    } catch (e) {
      return (
        points: const <WorkoutRoutePoint>[],
        failure: StorageFailure(e.toString()),
      );
    }
  }

  @override
  Future<({HealthSummary? summary, Failure? failure})> getToday() async {
    final result = await getSummaries(days: 1);
    if (result.failure != null) {
      return (summary: null, failure: result.failure);
    }
    return (
      summary: result.summaries.isNotEmpty ? result.summaries.first : null,
      failure: null,
    );
  }
}
