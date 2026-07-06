import 'package:health/health.dart';
import 'package:kynos/core/errors/failures.dart';
import 'package:kynos/domain/entities/health_summary.dart';
import 'package:kynos/domain/entities/workout_route_point.dart';
import 'package:kynos/domain/entities/workout_session.dart';
import 'package:kynos/domain/repositories/health_repository.dart';
import 'package:kynos/infrastructure/health/apple_workout_route_channel.dart';
import 'package:kynos/infrastructure/health/health_data_aggregator.dart';
import 'package:kynos/infrastructure/health/health_kit_workout_mapper.dart';
import 'package:logger/logger.dart';

/// iOS implementation of [HealthRepository] backed by Apple HealthKit.
///
/// Uses the `health` Flutter plugin under the hood.
/// All data remains on-device in compliance with Zero-Knowledge policy.
class HealthKitRepository implements HealthRepository {
  final Health _health = Health();
  final Logger _logger = Logger();
  bool _isConfigured = false;

  /// Types of health data KYNOS uses for recovery and training insights.
  ///
  /// Filtered at runtime via [Health.isDataTypeAvailable], then authorized
  /// flexibly so optional categories do not block core running metrics.
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

  static const List<List<HealthDataType>> _permissionGroups = [
    [
      HealthDataType.HEART_RATE_VARIABILITY_SDNN,
      HealthDataType.RESTING_HEART_RATE,
      HealthDataType.HEART_RATE,
      HealthDataType.STEPS,
      HealthDataType.DISTANCE_WALKING_RUNNING,
      HealthDataType.WORKOUT,
    ],
    [
      HealthDataType.SLEEP_ASLEEP,
      HealthDataType.SLEEP_DEEP,
      HealthDataType.SLEEP_LIGHT,
      HealthDataType.SLEEP_REM,
      HealthDataType.SLEEP_IN_BED,
    ],
    [
      HealthDataType.ACTIVE_ENERGY_BURNED,
      HealthDataType.BASAL_ENERGY_BURNED,
      HealthDataType.TOTAL_CALORIES_BURNED,
      HealthDataType.EXERCISE_TIME,
      HealthDataType.FLIGHTS_CLIMBED,
    ],
    [HealthDataType.RESPIRATORY_RATE, HealthDataType.BLOOD_OXYGEN],
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

    final fullRequestGranted = await _requestReadAccess(types);
    if (fullRequestGranted) return true;

    var anyGroupGranted = false;
    for (final group in _permissionGroups) {
      final availableGroup = group
          .where(types.contains)
          .toSet()
          .toList(growable: false);
      if (availableGroup.isEmpty) continue;

      final groupGranted = await _requestReadAccess(availableGroup);
      anyGroupGranted = anyGroupGranted || groupGranted;
    }

    return anyGroupGranted;
  }

  @override
  Future<bool> hasPermissions() async {
    await _ensureConfigured();
    final types = _types;
    if (types.isEmpty) return false;

    final permissions = types
        .map((_) => HealthDataAccess.READ)
        .toList(growable: false);

    try {
      return await _health.hasPermissions(types, permissions: permissions) ??
          false;
    } catch (e) {
      _logger.w('HealthKit permission check failed: $e');
      return false;
    }
  }

  @override
  Future<({WorkoutSession? workout, Failure? failure})> getWorkoutById({
    required String workoutId,
  }) async {
    try {
      await _ensureConfigured();
      final now = DateTime.now();
      final startTime = now.subtract(const Duration(days: 365 * 10));
      final points = await _health.getHealthDataFromTypes(
        types: const [HealthDataType.WORKOUT],
        startTime: startTime,
        endTime: now,
      );

      for (final point in points) {
        if (point.uuid != workoutId || !isRunningWorkout(point)) continue;
        return (workout: toWorkoutSession(point), failure: null);
      }

      return (workout: null, failure: null);
    } catch (e) {
      return (
        workout: null,
        failure: HealthDataFailure(e.toString()),
      );
    }
  }

  Future<bool> _requestReadAccess(List<HealthDataType> types) async {
    if (types.isEmpty) return false;

    final permissions = types
        .map((_) => HealthDataAccess.READ)
        .toList(growable: false);

    try {
      return await _health.requestAuthorization(
        types,
        permissions: permissions,
      );
    } catch (e) {
      _logger.w('HealthKit authorization request failed for $types: $e');
      return false;
    }
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

      return (summaries: aggregateHealthSummaries(data), failure: null);
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

      final runs = points.where(isRunningWorkout).map(toWorkoutSession).toList()
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
}
