import 'package:kynos/core/constants/imported_workout_ids.dart';
import 'package:kynos/core/errors/failures.dart';
import 'package:kynos/domain/entities/health_summary.dart';
import 'package:kynos/domain/entities/workout_route_point.dart';
import 'package:kynos/domain/entities/workout_session.dart';
import 'package:kynos/domain/repositories/health_repository.dart';

/// Merges platform HealthKit data with locally imported workouts.
class CompositeHealthRepository implements HealthRepository {
  CompositeHealthRepository({
    required HealthRepository healthKit,
    required HealthRepository imported,
  })  : _healthKit = healthKit,
        _imported = imported;

  final HealthRepository _healthKit;
  final HealthRepository _imported;

  static const _startTolerance = Duration(seconds: 60);
  static const _distanceToleranceMeters = 50.0;

  @override
  Future<bool> requestPermissions() => _healthKit.requestPermissions();

  @override
  Future<({List<HealthSummary> summaries, Failure? failure})> getSummaries({
    required int days,
  }) async {
    final healthKitResult = await _healthKit.getSummaries(days: days);
    final importedResult = await _imported.getSummaries(days: days);

    if (healthKitResult.failure != null && importedResult.failure != null) {
      return (
        summaries: const <HealthSummary>[],
        failure: healthKitResult.failure,
      );
    }

    return (
      summaries: _mergeSummaries(
        healthKitResult.summaries,
        importedResult.summaries,
      ),
      failure: null,
    );
  }

  @override
  Future<({List<WorkoutSession> runs, Failure? failure})> getRecentRuns({
    required int days,
    int limit = 30,
  }) async {
    final healthKitResult = await _healthKit.getRecentRuns(
      days: days,
      limit: limit,
    );
    final importedResult = await _imported.getRecentRuns(
      days: days,
      limit: limit,
    );

    if (healthKitResult.failure != null && importedResult.failure != null) {
      return (
        runs: const <WorkoutSession>[],
        failure: healthKitResult.failure,
      );
    }

    final merged = _mergeRuns(healthKitResult.runs, importedResult.runs);
    return (runs: merged.take(limit).toList(), failure: null);
  }

  @override
  Future<({List<WorkoutRoutePoint> points, Failure? failure})> getRunRoute({
    required String workoutUuid,
  }) async {
    if (ImportedWorkoutIds.isImported(workoutUuid)) {
      return _imported.getRunRoute(workoutUuid: workoutUuid);
    }
    return _healthKit.getRunRoute(workoutUuid: workoutUuid);
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

  List<WorkoutSession> _mergeRuns(
    List<WorkoutSession> healthKitRuns,
    List<WorkoutSession> importedRuns,
  ) {
    final merged = <WorkoutSession>[...healthKitRuns];

    for (final imported in importedRuns) {
      final duplicate = merged.any(
        (existing) => _isDuplicateRun(existing, imported),
      );
      if (!duplicate) {
        merged.add(imported);
      }
    }

    merged.sort((a, b) => b.start.compareTo(a.start));
    return merged;
  }

  bool _isDuplicateRun(WorkoutSession a, WorkoutSession b) {
    final startDelta = a.start.difference(b.start).abs();
    if (startDelta > _startTolerance) {
      return false;
    }

    final distanceA = a.distanceMeters ?? 0;
    final distanceB = b.distanceMeters ?? 0;
    return (distanceA - distanceB).abs() <= _distanceToleranceMeters;
  }

  List<HealthSummary> _mergeSummaries(
    List<HealthSummary> healthKitSummaries,
    List<HealthSummary> importedSummaries,
  ) {
    final byDay = <DateTime, HealthSummary>{
      for (final summary in healthKitSummaries) summary.date: summary,
    };

    for (final imported in importedSummaries) {
      final existing = byDay[imported.date];
      if (existing == null) {
        byDay[imported.date] = imported;
        continue;
      }

      byDay[imported.date] = _combineSummaries(existing, imported);
    }

    return byDay.values.toList()..sort((a, b) => b.date.compareTo(a.date));
  }

  HealthSummary _combineSummaries(HealthSummary base, HealthSummary extra) {
    return HealthSummary(
      date: base.date,
      hrvMs: base.hrvMs ?? extra.hrvMs,
      rhrBpm: base.rhrBpm ?? extra.rhrBpm,
      avgHeartRateBpm: base.avgHeartRateBpm ?? extra.avgHeartRateBpm,
      respiratoryRateBrpm: base.respiratoryRateBrpm ?? extra.respiratoryRateBrpm,
      bloodOxygenPercent: base.bloodOxygenPercent ?? extra.bloodOxygenPercent,
      sleepHours: base.sleepHours ?? extra.sleepHours,
      activeCalories: base.activeCalories ?? extra.activeCalories,
      basalCalories: base.basalCalories ?? extra.basalCalories,
      totalCalories: base.totalCalories ?? extra.totalCalories,
      steps: base.steps ?? extra.steps,
      distanceMeters: (base.distanceMeters ?? 0) + (extra.distanceMeters ?? 0),
      flightsClimbed: base.flightsClimbed ?? extra.flightsClimbed,
      runningPowerWatts: base.runningPowerWatts ?? extra.runningPowerWatts,
      cadenceSpm: base.cadenceSpm ?? extra.cadenceSpm,
      strideLengthMeters: base.strideLengthMeters ?? extra.strideLengthMeters,
      exerciseMinutes: base.exerciseMinutes ?? extra.exerciseMinutes,
      runningWorkoutCount:
          (base.runningWorkoutCount ?? 0) + (extra.runningWorkoutCount ?? 0),
      runningWorkoutMinutes: (base.runningWorkoutMinutes ?? 0) +
          (extra.runningWorkoutMinutes ?? 0),
      runningWorkoutDistanceMeters:
          (base.runningWorkoutDistanceMeters ?? 0) +
              (extra.runningWorkoutDistanceMeters ?? 0),
      runningWorkoutCalories: (base.runningWorkoutCalories ?? 0) +
          (extra.runningWorkoutCalories ?? 0),
    );
  }
}
