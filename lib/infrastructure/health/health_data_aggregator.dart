import 'package:health/health.dart';
import 'package:kynos/domain/entities/health_summary.dart';
import 'package:kynos/infrastructure/health/health_kit_workout_mapper.dart';

/// Aggregates raw HealthKit data points into daily [HealthSummary] values.
List<HealthSummary> aggregateHealthSummaries(List<HealthDataPoint> data) {
  final aggregated = <DateTime, _DailyAccumulator>{};

  for (final point in data) {
    final day = DateTime(point.dateFrom.year, point.dateFrom.month, point.dateFrom.day);
    final acc = aggregated.putIfAbsent(day, () => _DailyAccumulator(date: day));

    final numeric = _extractNumericValue(point.value);

    switch (point.type) {
      case HealthDataType.HEART_RATE_VARIABILITY_SDNN:
        if (numeric != null) acc.addHrv(numeric);
      case HealthDataType.RESTING_HEART_RATE:
        if (numeric != null) acc.addRhr(numeric);
      case HealthDataType.HEART_RATE:
        if (numeric != null) acc.addHeartRate(numeric);
      case HealthDataType.RESPIRATORY_RATE:
        if (numeric != null) acc.addRespiratoryRate(numeric);
      case HealthDataType.BLOOD_OXYGEN:
        if (numeric != null) acc.addBloodOxygen(numeric * 100);
      case HealthDataType.SLEEP_ASLEEP ||
            HealthDataType.SLEEP_DEEP ||
            HealthDataType.SLEEP_LIGHT ||
            HealthDataType.SLEEP_REM ||
            HealthDataType.SLEEP_IN_BED:
        if (numeric != null) {
          // health package converts sleep categories to minutes.
          acc.sleepMinutes += numeric;
        }
      case HealthDataType.ACTIVE_ENERGY_BURNED:
        if (numeric != null) acc.activeCalories += numeric;
      case HealthDataType.BASAL_ENERGY_BURNED:
        if (numeric != null) acc.basalCalories += numeric;
      case HealthDataType.TOTAL_CALORIES_BURNED:
        if (numeric != null) acc.totalCalories += numeric;
      case HealthDataType.STEPS:
        if (numeric != null) acc.steps += numeric.round();
      case HealthDataType.DISTANCE_WALKING_RUNNING:
        if (numeric != null) acc.distanceMeters += numeric;
      case HealthDataType.FLIGHTS_CLIMBED:
        if (numeric != null) acc.flightsClimbed += numeric;
      case HealthDataType.EXERCISE_TIME:
        if (numeric != null) acc.exerciseMinutes += numeric;
      case HealthDataType.WORKOUT:
        _addWorkoutContribution(point, acc);
      default:
        break;
    }
  }

  return aggregated.values
      .map((acc) => acc.toSummary())
      .toList()
    ..sort((a, b) => b.date.compareTo(a.date));
}

double? _extractNumericValue(HealthValue value) {
  if (value is NumericHealthValue) {
    return value.numericValue.toDouble();
  }
  return null;
}

void _addWorkoutContribution(HealthDataPoint point, _DailyAccumulator acc) {
  if (!isRunningWorkout(point)) {
    return;
  }

  acc.runningWorkoutCount += 1;
  acc.runningWorkoutMinutes += point.dateTo.difference(point.dateFrom).inMinutes.toDouble();

  final summary = point.workoutSummary;
  if (summary?.totalDistance != null) {
    acc.runningWorkoutDistanceMeters += summary!.totalDistance.toDouble();
  }
  if (summary?.totalEnergyBurned != null) {
    acc.runningWorkoutCalories += summary!.totalEnergyBurned.toDouble();
  }

  if (point.value is WorkoutHealthValue) {
    final value = point.value as WorkoutHealthValue;
    if (value.totalDistance != null) {
      acc.runningWorkoutDistanceMeters += value.totalDistance!;
    }
    if (value.totalEnergyBurned != null) {
      acc.runningWorkoutCalories += value.totalEnergyBurned!;
    }
  }
}

class _DailyAccumulator {
  _DailyAccumulator({required this.date});

  final DateTime date;

  double _hrvSum = 0;
  int _hrvCount = 0;

  double _rhrSum = 0;
  int _rhrCount = 0;

  double _heartRateSum = 0;
  int _heartRateCount = 0;

  double _respiratoryRateSum = 0;
  int _respiratoryRateCount = 0;

  double _bloodOxygenSum = 0;
  int _bloodOxygenCount = 0;

  double sleepMinutes = 0;
  double activeCalories = 0;
  double basalCalories = 0;
  double totalCalories = 0;
  int steps = 0;
  double distanceMeters = 0;
  double flightsClimbed = 0;
  double exerciseMinutes = 0;

  int runningWorkoutCount = 0;
  double runningWorkoutMinutes = 0;
  double runningWorkoutDistanceMeters = 0;
  double runningWorkoutCalories = 0;

  void addHrv(double value) {
    _hrvSum += value;
    _hrvCount += 1;
  }

  void addRhr(double value) {
    _rhrSum += value;
    _rhrCount += 1;
  }

  void addHeartRate(double value) {
    _heartRateSum += value;
    _heartRateCount += 1;
  }

  void addRespiratoryRate(double value) {
    _respiratoryRateSum += value;
    _respiratoryRateCount += 1;
  }

  void addBloodOxygen(double value) {
    _bloodOxygenSum += value;
    _bloodOxygenCount += 1;
  }

  HealthSummary toSummary() {
    return HealthSummary(
      date: date,
      hrvMs: _hrvCount == 0 ? null : _hrvSum / _hrvCount,
      rhrBpm: _rhrCount == 0 ? null : _rhrSum / _rhrCount,
      avgHeartRateBpm: _heartRateCount == 0 ? null : _heartRateSum / _heartRateCount,
      respiratoryRateBrpm:
          _respiratoryRateCount == 0 ? null : _respiratoryRateSum / _respiratoryRateCount,
      bloodOxygenPercent:
          _bloodOxygenCount == 0 ? null : _bloodOxygenSum / _bloodOxygenCount,
      sleepHours: sleepMinutes == 0 ? null : sleepMinutes / 60,
      activeCalories: activeCalories == 0 ? null : activeCalories,
      basalCalories: basalCalories == 0 ? null : basalCalories,
      totalCalories: totalCalories == 0 ? null : totalCalories,
      steps: steps == 0 ? null : steps,
      distanceMeters: distanceMeters == 0 ? null : distanceMeters,
      flightsClimbed: flightsClimbed == 0 ? null : flightsClimbed,
      exerciseMinutes: exerciseMinutes == 0 ? null : exerciseMinutes,
      runningWorkoutCount: runningWorkoutCount == 0 ? null : runningWorkoutCount,
      runningWorkoutMinutes: runningWorkoutMinutes == 0 ? null : runningWorkoutMinutes,
      runningWorkoutDistanceMeters:
          runningWorkoutDistanceMeters == 0 ? null : runningWorkoutDistanceMeters,
      runningWorkoutCalories:
          runningWorkoutCalories == 0 ? null : runningWorkoutCalories,
    );
  }
}
