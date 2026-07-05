import 'package:health/health.dart';
import 'package:kynos/core/errors/failures.dart';
import 'package:kynos/domain/entities/health_summary.dart';
import 'package:kynos/domain/entities/workout_route_point.dart';
import 'package:kynos/domain/entities/workout_session.dart';
import 'package:kynos/domain/repositories/health_repository.dart';
import 'package:kynos/infrastructure/health/apple_workout_route_channel.dart';
import 'package:kynos/infrastructure/health/health_data_aggregator.dart';
import 'package:kynos/infrastructure/health/health_kit_workout_mapper.dart';

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

      final runs = points
          .where(isRunningWorkout)
          .map(toWorkoutSession)
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
}
