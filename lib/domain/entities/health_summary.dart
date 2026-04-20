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

  /// Running power in Watts (if available from wearable).
  final double? runningPowerWatts;

  /// Running cadence (steps per minute).
  final double? cadenceSpm;

  /// Running stride length in meters.
  final double? strideLengthMeters;

  /// Total exercise duration in minutes.
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
        'stride_length_m': strideLengthMeters,
        'exercise_minutes': exerciseMinutes,
      };
}
