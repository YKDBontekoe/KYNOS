import 'package:health/health.dart';
import 'package:kynos/core/errors/failures.dart';
import 'package:kynos/domain/entities/health_summary.dart';
import 'package:kynos/domain/repositories/health_repository.dart';

/// iOS implementation of [HealthRepository] backed by Apple HealthKit.
///
/// Uses the `health` Flutter plugin under the hood.
/// All data remains on-device in compliance with Zero-Knowledge policy.
class HealthKitRepository implements HealthRepository {
  final Health _health = Health();
  bool _isConfigured = false;

  /// Types of health data KYNOS requires for biomechanical coaching.
  static final List<HealthDataType> _types = [
    HealthDataType.HEART_RATE_VARIABILITY_SDNN,
    HealthDataType.RESTING_HEART_RATE,
    HealthDataType.SLEEP_ASLEEP,
    HealthDataType.SLEEP_IN_BED,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.STEPS,
    HealthDataType.DISTANCE_WALKING_RUNNING,
    HealthDataType.EXERCISE_TIME,
  ];

  Future<void> _ensureConfigured() async {
    if (!_isConfigured) {
      await _health.configure();
      _isConfigured = true;
    }
  }

  @override
  Future<bool> requestPermissions() async {
    await _ensureConfigured();
    // Explicitly demand READ-ONLY access. By default ^12.2.0 tries
    // READ_WRITE, which can crash if iOS rejects write capabilities.
    final permissions = _types.map((_) => HealthDataAccess.READ).toList();
    return _health.requestAuthorization(_types, permissions: permissions);
  }

  @override
  Future<({List<HealthSummary> summaries, Failure? failure})> getSummaries({
    required int days,
  }) async {
    try {
      await _ensureConfigured();
      final now = DateTime.now();
      final startTime = now.subtract(Duration(days: days));

      final List<HealthDataPoint> data = await _health.getHealthDataFromTypes(
        types: _types,
        startTime: startTime,
        endTime: now,
      );

      final Map<DateTime, _DailyAccumulator> aggregated =
          <DateTime, _DailyAccumulator>{};

      for (final point in data) {
        final date = DateTime(
          point.dateFrom.year,
          point.dateFrom.month,
          point.dateFrom.day,
        );
        final entry = aggregated.putIfAbsent(date, _DailyAccumulator.new);

        if (point.type == HealthDataType.HEART_RATE_VARIABILITY_SDNN) {
          entry.hrvMs = _asNumeric(point);
          continue;
        }
        if (point.type == HealthDataType.RESTING_HEART_RATE) {
          entry.rhrBpm = _asNumeric(point);
          continue;
        }
        if (point.type == HealthDataType.SLEEP_ASLEEP ||
            point.type == HealthDataType.SLEEP_IN_BED) {
          entry.sleepHours +=
              point.dateTo.difference(point.dateFrom).inMinutes / 60.0;
          continue;
        }
        if (point.type == HealthDataType.ACTIVE_ENERGY_BURNED) {
          entry.activeCalories += _asNumeric(point) ?? 0;
          continue;
        }
        if (point.type == HealthDataType.STEPS) {
          entry.steps += _asNumeric(point) ?? 0;
          continue;
        }
        if (point.type == HealthDataType.DISTANCE_WALKING_RUNNING ||
            point.type == HealthDataType.DISTANCE_DELTA) {
          entry.distanceMeters += _asNumeric(point) ?? 0;
          continue;
        }
        if (point.type == HealthDataType.EXERCISE_TIME) {
          entry.exerciseMinutes += _asNumeric(point) ?? 0;
          continue;
        }
        if (point.type == HealthDataType.WORKOUT) {
          final workout = point.value;
          if (workout is! WorkoutHealthValue) {
            continue;
          }
          final isRunWorkout =
              workout.workoutActivityType ==
                  HealthWorkoutActivityType.RUNNING ||
              workout.workoutActivityType ==
                  HealthWorkoutActivityType.RUNNING_TREADMILL;
          if (!isRunWorkout) {
            continue;
          }
          if (workout.totalDistance != null) {
            entry.distanceMeters += workout.totalDistance!.toDouble();
          }
          if (workout.totalSteps != null) {
            entry.steps += workout.totalSteps!.toDouble();
          }
          entry.exerciseMinutes += point.dateTo
              .difference(point.dateFrom)
              .inMinutes;
        }
      }

      final summaries =
          aggregated.entries
              .map((entry) => entry.value.toSummary(date: entry.key))
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
  Future<({HealthSummary? summary, Failure? failure})> getToday() async {
    // days: 1 = past 24 h — covers today regardless of time-of-day.
    // days: 0 would set startTime = endTime = now (zero-second window).
    final result = await getSummaries(days: 1);
    if (result.failure != null) {
      return (summary: null, failure: result.failure);
    }
    return (
      summary: result.summaries.isNotEmpty ? result.summaries.first : null,
      failure: null,
    );
  }

  double? _asNumeric(HealthDataPoint point) {
    final value = point.value;
    if (value is NumericHealthValue) {
      return value.numericValue.toDouble();
    }
    return null;
  }
}

class _DailyAccumulator {
  double? hrvMs;
  double? rhrBpm;
  double sleepHours = 0;
  double activeCalories = 0;
  double steps = 0;
  double distanceMeters = 0;
  double exerciseMinutes = 0;

  HealthSummary toSummary({required DateTime date}) {
    final cadence = exerciseMinutes > 0 ? steps / exerciseMinutes : null;
    final strideLength = steps > 0 ? distanceMeters / steps : null;

    // Convert kcal over active duration into estimated mechanical power.
    final powerWatts = (exerciseMinutes > 0 && activeCalories > 0)
        ? (activeCalories * 4184.0) / (exerciseMinutes * 60.0)
        : null;

    return HealthSummary(
      date: date,
      hrvMs: hrvMs,
      rhrBpm: rhrBpm,
      sleepHours: sleepHours > 0 ? sleepHours : null,
      activeCalories: activeCalories > 0 ? activeCalories : null,
      runningPowerWatts: powerWatts,
      cadenceSpm: cadence,
      strideLengthMeters: strideLength,
      exerciseMinutes: exerciseMinutes > 0 ? exerciseMinutes : null,
    );
  }
}
