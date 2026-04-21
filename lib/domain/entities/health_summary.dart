/// Aggregated biometric snapshot used by the AI coaching agent.
///
/// Sourced from Apple HealthKit (iOS) or Google Health Connect (Android).
class HealthSummary {
  final DateTime date;

  /// Heart Rate Variability — higher is generally better recovery.
  final double? hrvMs;

  /// Resting Heart Rate (bpm).
  final double? rhrBpm;

  /// Average heart rate (bpm).
  final double? avgHeartRateBpm;

  /// Respiratory rate (breaths/min).
  final double? respiratoryRateBrpm;

  /// Blood oxygen saturation (%).
  final double? bloodOxygenPercent;

  /// Sleep duration in hours.
  final double? sleepHours;

  /// Active energy expenditure in kcal.
  final double? activeCalories;

  /// Basal energy expenditure in kcal.
  final double? basalCalories;

  /// Total calories burned in kcal.
  final double? totalCalories;

  /// Daily steps.
  final int? steps;

  /// Daily distance in meters.
  final double? distanceMeters;

  /// Daily floors climbed.
  final double? flightsClimbed;

  /// Running power in Watts (if available from wearable).
  final double? runningPowerWatts;

  /// Running cadence (steps per minute).
  final double? cadenceSpm;

  /// Running stride length in meters.
  final double? strideLengthMeters;

  /// Total exercise duration in minutes.
  final double? exerciseMinutes;

  /// Number of running workouts detected in this day.
  final int? runningWorkoutCount;

  /// Total running workout duration in minutes.
  final double? runningWorkoutMinutes;

  /// Total running workout distance in meters.
  final double? runningWorkoutDistanceMeters;

  /// Total running workout calories.
  final double? runningWorkoutCalories;

  const HealthSummary({
    required this.date,
    this.hrvMs,
    this.rhrBpm,
    this.avgHeartRateBpm,
    this.respiratoryRateBrpm,
    this.bloodOxygenPercent,
    this.sleepHours,
    this.activeCalories,
    this.basalCalories,
    this.totalCalories,
    this.steps,
    this.distanceMeters,
    this.flightsClimbed,
    this.runningPowerWatts,
    this.cadenceSpm,
    this.strideLengthMeters,
    this.exerciseMinutes,
    this.runningWorkoutCount,
    this.runningWorkoutMinutes,
    this.runningWorkoutDistanceMeters,
    this.runningWorkoutCalories,
  });

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'hrv_ms': hrvMs,
        'rhr_bpm': rhrBpm,
        'avg_heart_rate_bpm': avgHeartRateBpm,
        'respiratory_rate_brpm': respiratoryRateBrpm,
        'blood_oxygen_percent': bloodOxygenPercent,
        'sleep_hours': sleepHours,
        'active_calories': activeCalories,
        'basal_calories': basalCalories,
        'total_calories': totalCalories,
        'steps': steps,
        'distance_meters': distanceMeters,
        'flights_climbed': flightsClimbed,
        'running_power_watts': runningPowerWatts,
        'cadence_spm': cadenceSpm,
        'stride_length_m': strideLengthMeters,
        'exercise_minutes': exerciseMinutes,
        'running_workout_count': runningWorkoutCount,
        'running_workout_minutes': runningWorkoutMinutes,
        'running_workout_distance_m': runningWorkoutDistanceMeters,
        'running_workout_calories': runningWorkoutCalories,
      };
}
