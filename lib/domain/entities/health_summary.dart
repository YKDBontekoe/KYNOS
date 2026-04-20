/// Aggregated biometric snapshot used by the AI coaching agent.
///
/// Sourced from Apple HealthKit (iOS) or Google Health Connect (Android).
class HealthSummary {
  final DateTime date;

  /// Heart Rate Variability — higher is generally better recovery.
  final double? hrvMs;

  /// Resting Heart Rate (bpm).
  final double? rhrBpm;

  /// Sleep duration in hours.
  final double? sleepHours;

  /// Active energy expenditure in kcal.
  final double? activeCalories;

  /// Running power in Watts (estimated when direct power stream is unavailable).
  final double? runningPowerWatts;

  /// Average running cadence (steps per minute) for the day.
  final double? cadenceSpm;

  /// Average stride length (meters per step) for the day.
  final double? strideLengthMeters;

  /// Total exercise duration captured for the day (minutes).
  final double? exerciseMinutes;

  const HealthSummary({
    required this.date,
    this.hrvMs,
    this.rhrBpm,
    this.sleepHours,
    this.activeCalories,
    this.runningPowerWatts,
    this.cadenceSpm,
    this.strideLengthMeters,
    this.exerciseMinutes,
  });

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'hrv_ms': hrvMs,
    'rhr_bpm': rhrBpm,
    'sleep_hours': sleepHours,
    'active_calories': activeCalories,
    'running_power_watts': runningPowerWatts,
    'cadence_spm': cadenceSpm,
    'stride_length_meters': strideLengthMeters,
    'exercise_minutes': exerciseMinutes,
  };
}
