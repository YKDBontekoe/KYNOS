import 'package:drift/drift.dart';
import 'package:kynos/domain/entities/workout_route_point.dart';
import 'package:kynos/domain/entities/workout_session.dart';
import 'package:kynos/infrastructure/health/imported_health_database.dart';
import 'package:kynos/infrastructure/health/imported_health_store.dart';

/// Drift-backed store for imported workouts on native platforms.
class DriftImportedHealthStore implements ImportedHealthStore {
  DriftImportedHealthStore(this._db);

  final ImportedHealthDatabase _db;

  @override
  Future<int> workoutCount() async {
    final count = await _db.select(_db.importedWorkouts).get();
    return count.length;
  }

  @override
  Future<List<WorkoutSession>> getWorkouts({
    required DateTime since,
    int? limit,
  }) async {
    final query = _db.select(_db.importedWorkouts)
      ..where((row) => row.start.isBiggerOrEqualValue(since))
      ..orderBy([(row) => OrderingTerm.desc(row.start)]);

    if (limit != null) {
      query.limit(limit);
    }

    final rows = await query.get();
    return rows.map(_toWorkoutSession).toList();
  }

  @override
  Future<List<WorkoutRoutePoint>> getRoutePoints(String workoutId) async {
    final rows = await (_db.select(_db.importedRoutePoints)
          ..where((row) => row.workoutId.equals(workoutId))
          ..orderBy([(row) => OrderingTerm.asc(row.sequence)]))
        .get();

    return rows
        .map(
          (row) => WorkoutRoutePoint(
            latitude: row.latitude,
            longitude: row.longitude,
            timestamp: row.timestamp,
          ),
        )
        .toList();
  }

  @override
  Future<void> saveWorkout({
    required WorkoutSession workout,
    List<WorkoutRoutePoint> routePoints = const [],
  }) async {
    await _db.transaction(() async {
      await _db.into(_db.importedWorkouts).insertOnConflictUpdate(
            ImportedWorkoutsCompanion.insert(
              id: workout.id,
              start: workout.start,
              end: workout.end,
              workoutType: workout.workoutType,
              distanceMeters: Value(workout.distanceMeters),
              energyKcal: Value(workout.energyKcal),
              steps: Value(workout.steps),
              sourceName: workout.sourceName,
              startLatitude: Value(workout.startLatitude),
              startLongitude: Value(workout.startLongitude),
              endLatitude: Value(workout.endLatitude),
              endLongitude: Value(workout.endLongitude),
            ),
          );

      await (_db.delete(_db.importedRoutePoints)
            ..where((row) => row.workoutId.equals(workout.id)))
          .go();

      if (routePoints.isNotEmpty) {
        await _db.batch((batch) {
          batch.insertAll(
            _db.importedRoutePoints,
            [
              for (var i = 0; i < routePoints.length; i++)
                ImportedRoutePointsCompanion.insert(
                  workoutId: workout.id,
                  latitude: routePoints[i].latitude,
                  longitude: routePoints[i].longitude,
                  timestamp: Value(routePoints[i].timestamp),
                  sequence: i,
                ),
            ],
          );
        });
      }
    });
  }

  @override
  Future<void> clearAll() async {
    await _db.transaction(() async {
      await _db.delete(_db.importedRoutePoints).go();
      await _db.delete(_db.importedWorkouts).go();
    });
  }

  WorkoutSession _toWorkoutSession(ImportedWorkout row) {
    return WorkoutSession(
      id: row.id,
      start: row.start,
      end: row.end,
      workoutType: row.workoutType,
      distanceMeters: row.distanceMeters,
      energyKcal: row.energyKcal,
      steps: row.steps,
      sourceName: row.sourceName,
      startLatitude: row.startLatitude,
      startLongitude: row.startLongitude,
      endLatitude: row.endLatitude,
      endLongitude: row.endLongitude,
    );
  }
}
