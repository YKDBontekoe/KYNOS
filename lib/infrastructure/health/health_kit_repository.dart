import 'package:health/health.dart';
import 'package:kynos/core/errors/failures.dart';
import 'package:kynos/domain/entities/health_summary.dart';
import 'package:kynos/domain/entities/workout_route_point.dart';
import 'package:kynos/domain/entities/workout_session.dart';
import 'package:kynos/domain/repositories/health_repository.dart';
import 'package:kynos/infrastructure/health/apple_workout_route_channel.dart';

/// iOS implementation of [HealthRepository] backed by Apple HealthKit.
///
/// Uses the `health` Flutter plugin under the hood.
/// All data remains on-device in compliance with Zero-Knowledge policy.
class HealthKitRepository implements HealthRepository {
  final Health _health = Health();
  bool _isConfigured = false;

  /// Types of health data KYNOS uses for recovery and training insights.
  ///
  /// Filtered at runtime via [Health.isDataTypeAvailable] so Android-only
  /// entries (e.g. [HealthDataType.TOTAL_CALORIES_BURNED]) are never sent
  /// to HealthKit — that would map to the wrong native type and can prevent
  /// the authorization sheet from appearing.
  static const List<HealthDataType> _requestedTypes = [
    HealthDataType.HEART_RATE_VARIABILITY_SDNN,
    HealthDataType.RESTING_HEART_RATE,
    HealthDataType.HEART_RATE,
    HealthDataType.RESPIRATORY_RATE,
    HealthDataType.BLOOD_OXYGEN,
    HealthDataType.SLEEP_ASLEEP,
    HealthDataType.SLEEP_DEEP,
    HealthDataType.SLEEP_LIGHT,
    HealthDataType.SLEEP_REM,
    HealthDataType.SLEEP_IN_BED,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.BASAL_ENERGY_BURNED,
    HealthDataType.TOTAL_CALORIES_BURNED,
    HealthDataType.STEPS,
    HealthDataType.DISTANCE_WALKING_RUNNING,
    HealthDataType.FLIGHTS_CLIMBED,
    HealthDataType.EXERCISE_TIME,
    HealthDataType.WORKOUT,
  ];

  List<HealthDataType> get _types => _requestedTypes
      .where(_health.isDataTypeAvailable)
      .toList(growable: false);

  Future<void> _ensureConfigured() async {
    if (!_isConfigured) {
      await _health.configure();
      _isConfigured = true;
    }
  }

  @override
  Future<bool> requestPermissions() async {
    await _ensureConfigured();
    final types = _types;
    if (types.isEmpty) return false;

    // Explicitly demand READ-only access. The health plugin defaults to
    // READ_WRITE, which iOS rejects when write entitlements are absent.
    final permissions = types.map((_) => HealthDataAccess.READ).toList();
    return _health.requestAuthorization(types, permissions: permissions);
  }

  @override
  Future<({List<HealthSummary> summaries, Failure? failure})> getSummaries({
    required int days,
  }) async {
    try {
      await _ensureConfigured();
      final now = DateTime.now();
      final startTime = now.subtract(Duration(days: days));

      final data = await _health.getHealthDataFromTypes(
        types: _types,
        startTime: startTime,
        endTime: now,
      );

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

      final summaries = aggregated.values
          .map((acc) => acc.toSummary())
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));

      return (summaries: summaries, failure: null);
    } catch (e) {
      return (
        summaries: const <HealthSummary>[],
        failure: HealthDataFailure(e.toString()),
      );
    }
  }

  @override
  Future<({List<WorkoutSession> runs, Failure? failure})> getRecentRuns({
    required int days,
    int limit = 30,
  }) async {
    try {
      await _ensureConfigured();
      final now = DateTime.now();
      final startTime = now.subtract(Duration(days: days));
      final points = await _health.getHealthDataFromTypes(
        types: const [HealthDataType.WORKOUT],
        startTime: startTime,
        endTime: now,
      );

      final runs = points
          .where(_isRunningWorkout)
          .map(_toWorkoutSession)
          .toList()
        ..sort((a, b) => b.start.compareTo(a.start));

      return (runs: runs.take(limit).toList(), failure: null);
    } catch (e) {
      return (
        runs: const <WorkoutSession>[],
        failure: HealthDataFailure(e.toString()),
      );
    }
  }


  @override
  Future<({List<WorkoutRoutePoint> points, Failure? failure})> getRunRoute({
    required String workoutUuid,
  }) async {
    try {
      final points = await AppleWorkoutRouteChannel.getWorkoutRoute(
        workoutUuid: workoutUuid,
      );
      return (points: points, failure: null);
    } catch (e) {
      return (
        points: const <WorkoutRoutePoint>[],
        failure: HealthDataFailure(e.toString()),
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

  static double? _extractNumericValue(HealthValue value) {
    if (value is NumericHealthValue) {
      return value.numericValue.toDouble();
    }
    return null;
  }

  static void _addWorkoutContribution(HealthDataPoint point, _DailyAccumulator acc) {
    if (!_isRunningWorkout(point)) {
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

  static bool _isRunningWorkout(HealthDataPoint point) {
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

  static WorkoutSession _toWorkoutSession(HealthDataPoint point) {
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
      distanceMeters: _distanceMeters(point),
      energyKcal: _energyKcal(point),
      steps: _steps(point),
      sourceName: point.sourceName,
      startLatitude: _extractCoordinate(metadata, const [
        'startLatitude',
        'start_latitude',
        'route_start_latitude',
      ]),
      startLongitude: _extractCoordinate(metadata, const [
        'startLongitude',
        'start_longitude',
        'route_start_longitude',
      ]),
      endLatitude: _extractCoordinate(metadata, const [
        'endLatitude',
        'end_latitude',
        'route_end_latitude',
      ]),
      endLongitude: _extractCoordinate(metadata, const [
        'endLongitude',
        'end_longitude',
        'route_end_longitude',
      ]),
    );
  }

  static double? _distanceMeters(HealthDataPoint point) {
    if (point.workoutSummary?.totalDistance != null) {
      return point.workoutSummary!.totalDistance.toDouble();
    }
    if (point.value is WorkoutHealthValue) {
      return (point.value as WorkoutHealthValue).totalDistance?.toDouble();
    }
    return null;
  }

  static double? _energyKcal(HealthDataPoint point) {
    if (point.workoutSummary?.totalEnergyBurned != null) {
      return point.workoutSummary!.totalEnergyBurned.toDouble();
    }
    if (point.value is WorkoutHealthValue) {
      return (point.value as WorkoutHealthValue).totalEnergyBurned?.toDouble();
    }
    return null;
  }

  static int? _steps(HealthDataPoint point) {
    if (point.workoutSummary?.totalSteps != null) {
      return point.workoutSummary!.totalSteps.toInt();
    }
    if (point.value is WorkoutHealthValue) {
      return (point.value as WorkoutHealthValue).totalSteps;
    }
    return null;
  }

  static double? _extractCoordinate(
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
