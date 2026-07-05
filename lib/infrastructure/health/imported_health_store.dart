import 'package:kynos/domain/entities/workout_route_point.dart';
import 'package:kynos/domain/entities/workout_session.dart';

/// Contract for locally persisted imported workouts.
abstract interface class ImportedHealthStore {
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

  Future<void> clearAll();
}

Map<String, dynamic> workoutSessionToJson(WorkoutSession workout) {
  return {
    'id': workout.id,
    'start': workout.start.toIso8601String(),
    'end': workout.end.toIso8601String(),
    'workoutType': workout.workoutType,
    'distanceMeters': workout.distanceMeters,
    'energyKcal': workout.energyKcal,
    'steps': workout.steps,
    'sourceName': workout.sourceName,
    'startLatitude': workout.startLatitude,
    'startLongitude': workout.startLongitude,
    'endLatitude': workout.endLatitude,
    'endLongitude': workout.endLongitude,
  };
}

WorkoutSession workoutSessionFromJson(Map<String, dynamic> json) {
  return WorkoutSession(
    id: json['id'] as String,
    start: DateTime.parse(json['start'] as String),
    end: DateTime.parse(json['end'] as String),
    workoutType: json['workoutType'] as String,
    distanceMeters: (json['distanceMeters'] as num?)?.toDouble(),
    energyKcal: (json['energyKcal'] as num?)?.toDouble(),
    steps: json['steps'] as int?,
    sourceName: json['sourceName'] as String,
    startLatitude: (json['startLatitude'] as num?)?.toDouble(),
    startLongitude: (json['startLongitude'] as num?)?.toDouble(),
    endLatitude: (json['endLatitude'] as num?)?.toDouble(),
    endLongitude: (json['endLongitude'] as num?)?.toDouble(),
  );
}

List<Map<String, dynamic>> routePointsToJson(List<WorkoutRoutePoint> points) {
  return points
      .map(
        (point) => {
          'latitude': point.latitude,
          'longitude': point.longitude,
          'timestamp': point.timestamp?.toIso8601String(),
        },
      )
      .toList();
}

List<WorkoutRoutePoint> routePointsFromJson(List<dynamic> json) {
  return json
      .map(
        (entry) {
          final map = Map<String, dynamic>.from(entry as Map);
          return WorkoutRoutePoint(
            latitude: (map['latitude'] as num).toDouble(),
            longitude: (map['longitude'] as num).toDouble(),
            timestamp: map['timestamp'] == null
                ? null
                : DateTime.tryParse(map['timestamp'] as String),
          );
        },
      )
      .toList();
}
