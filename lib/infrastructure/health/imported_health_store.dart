import 'package:kynos/domain/entities/health_summary.dart';
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

  Future<List<HealthSummary>> getSummaries({required DateTime since});

  Future<void> saveSummaries(List<HealthSummary> summaries);

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

Map<String, dynamic> healthSummaryToJson(HealthSummary summary) {
  return summary.toJson();
}

HealthSummary healthSummaryFromJson(Map<String, dynamic> json) {
  return HealthSummary(
    date: DateTime.parse(json['date'] as String),
    hrvMs: (json['hrv_ms'] as num?)?.toDouble(),
    rhrBpm: (json['rhr_bpm'] as num?)?.toDouble(),
    avgHeartRateBpm: (json['avg_heart_rate_bpm'] as num?)?.toDouble(),
    respiratoryRateBrpm: (json['respiratory_rate_brpm'] as num?)?.toDouble(),
    bloodOxygenPercent: (json['blood_oxygen_percent'] as num?)?.toDouble(),
    sleepHours: (json['sleep_hours'] as num?)?.toDouble(),
    activeCalories: (json['active_calories'] as num?)?.toDouble(),
    basalCalories: (json['basal_calories'] as num?)?.toDouble(),
    totalCalories: (json['total_calories'] as num?)?.toDouble(),
    steps: json['steps'] as int?,
    distanceMeters: (json['distance_meters'] as num?)?.toDouble(),
    flightsClimbed: (json['flights_climbed'] as num?)?.toDouble(),
    runningPowerWatts: (json['running_power_watts'] as num?)?.toDouble(),
    cadenceSpm: (json['cadence_spm'] as num?)?.toDouble(),
    strideLengthMeters: (json['stride_length_m'] as num?)?.toDouble(),
    exerciseMinutes: (json['exercise_minutes'] as num?)?.toDouble(),
    runningWorkoutCount: json['running_workout_count'] as int?,
    runningWorkoutMinutes:
        (json['running_workout_minutes'] as num?)?.toDouble(),
    runningWorkoutDistanceMeters:
        (json['running_workout_distance_m'] as num?)?.toDouble(),
    runningWorkoutCalories:
        (json['running_workout_calories'] as num?)?.toDouble(),
  );
}
