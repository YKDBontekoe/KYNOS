import 'package:kynos/domain/entities/health_summary.dart';
import 'package:kynos/domain/entities/workout_route_point.dart';
import 'package:kynos/domain/entities/workout_session.dart';

/// Domain-safe persistence boundary for locally imported health data.
abstract interface class ImportedHealthPersistence {
  Future<int> workoutCount();

  Future<List<WorkoutSession>> getWorkouts({
    required DateTime since,
    int? limit,
  });

  Future<List<WorkoutRoutePoint>> getRoutePoints(String workoutId);

  Future<void> saveWorkout({
    required WorkoutSession workout,
    List<WorkoutRoutePoint> routePoints = const [],
  });

  Future<List<HealthSummary>> getSummaries({required DateTime since});

  Future<void> saveSummaries(List<HealthSummary> summaries);

  Future<void> clearAll();
}
