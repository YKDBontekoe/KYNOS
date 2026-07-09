import 'package:kynos/domain/entities/health_summary.dart';
import 'package:kynos/infrastructure/health/health_summary_merge.dart';

/// Merges imported daily summaries, preferring stored metrics and adding
/// workout rollups from both sources.
List<HealthSummary> mergeImportedSummaries(
  List<HealthSummary> stored,
  List<HealthSummary> fromWorkouts,
) {
  final byDay = <DateTime, HealthSummary>{
    for (final summary in stored) summary.date: summary,
  };

  for (final workoutSummary in fromWorkouts) {
    final existing = byDay[workoutSummary.date];
    if (existing == null) {
      byDay[workoutSummary.date] = workoutSummary;
      continue;
    }
    byDay[workoutSummary.date] = _combine(existing, workoutSummary);
  }

  return byDay.values.toList()..sort((a, b) => b.date.compareTo(a.date));
}

HealthSummary _combine(HealthSummary base, HealthSummary extra) {
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
    runningWorkoutCount: HealthSummaryMerge.runningWorkoutCount(
      a: base.runningWorkoutCount,
      b: extra.runningWorkoutCount,
      distanceA: base.runningWorkoutDistanceMeters,
      distanceB: extra.runningWorkoutDistanceMeters,
    ),
    runningWorkoutMinutes: (base.runningWorkoutMinutes ?? 0) +
        (extra.runningWorkoutMinutes ?? 0),
    runningWorkoutDistanceMeters: HealthSummaryMerge.runningWorkoutDistanceMeters(
      base.runningWorkoutDistanceMeters,
      extra.runningWorkoutDistanceMeters,
    ),
    runningWorkoutCalories: (base.runningWorkoutCalories ?? 0) +
        (extra.runningWorkoutCalories ?? 0),
  );
}
