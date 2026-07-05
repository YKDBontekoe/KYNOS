import 'package:health/health.dart';
import 'package:kynos/domain/entities/workout_session.dart';

/// Returns true when [point] represents a running workout.
bool isRunningWorkout(HealthDataPoint point) {
  final workoutType = point.workoutSummary?.workoutType.toUpperCase();
  if (workoutType != null && workoutType.contains('RUN')) {
    return true;
  }

  if (point.value is WorkoutHealthValue) {
    final value = point.value as WorkoutHealthValue;
    return value.workoutActivityType.name.contains('RUN');
  }

  return false;
}

/// Maps a HealthKit workout data point to a [WorkoutSession].
WorkoutSession toWorkoutSession(HealthDataPoint point) {
  final summary = point.workoutSummary;
  final metadata = point.metadata;

  return WorkoutSession(
    id: point.uuid,
    start: point.dateFrom,
    end: point.dateTo,
    workoutType: summary?.workoutType ??
        (point.value is WorkoutHealthValue
            ? (point.value as WorkoutHealthValue).workoutActivityType.name
            : 'RUNNING'),
    distanceMeters: distanceMeters(point),
    energyKcal: energyKcal(point),
    steps: steps(point),
    sourceName: point.sourceName,
    startLatitude: extractCoordinate(metadata, const [
      'startLatitude',
      'start_latitude',
      'route_start_latitude',
    ]),
    startLongitude: extractCoordinate(metadata, const [
      'startLongitude',
      'start_longitude',
      'route_start_longitude',
    ]),
    endLatitude: extractCoordinate(metadata, const [
      'endLatitude',
      'end_latitude',
      'route_end_latitude',
    ]),
    endLongitude: extractCoordinate(metadata, const [
      'endLongitude',
      'end_longitude',
      'route_end_longitude',
    ]),
  );
}

double? distanceMeters(HealthDataPoint point) {
  if (point.workoutSummary?.totalDistance != null) {
    return point.workoutSummary!.totalDistance.toDouble();
  }
  if (point.value is WorkoutHealthValue) {
    return (point.value as WorkoutHealthValue).totalDistance?.toDouble();
  }
  return null;
}

double? energyKcal(HealthDataPoint point) {
  if (point.workoutSummary?.totalEnergyBurned != null) {
    return point.workoutSummary!.totalEnergyBurned.toDouble();
  }
  if (point.value is WorkoutHealthValue) {
    return (point.value as WorkoutHealthValue).totalEnergyBurned?.toDouble();
  }
  return null;
}

int? steps(HealthDataPoint point) {
  if (point.workoutSummary?.totalSteps != null) {
    return point.workoutSummary!.totalSteps.toInt();
  }
  if (point.value is WorkoutHealthValue) {
    return (point.value as WorkoutHealthValue).totalSteps;
  }
  return null;
}

double? extractCoordinate(
  Map<String, dynamic>? metadata,
  List<String> keys,
) {
  if (metadata == null) {
    return null;
  }

  for (final key in keys) {
    final value = metadata[key];
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      final parsed = double.tryParse(value);
      if (parsed != null) {
        return parsed;
      }
    }
  }
  return null;
}
