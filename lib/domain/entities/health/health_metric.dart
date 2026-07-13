import 'package:kynos/domain/entities/health_summary.dart';

/// Health signals the wellbeing coach may inspect and visualise.
enum HealthMetric {
  hrv('HRV', 'ms'),
  restingHeartRate('Resting heart rate', 'bpm'),
  averageHeartRate('Average heart rate', 'bpm'),
  respiratoryRate('Respiratory rate', 'breaths/min'),
  bloodOxygen('Blood oxygen', '%'),
  sleep('Sleep', 'h'),
  steps('Steps', 'steps'),
  distance('Distance', 'km'),
  exerciseTime('Exercise', 'min'),
  activeEnergy('Active energy', 'kcal'),
  totalEnergy('Total energy', 'kcal'),
  selfReportedEnergy('Energy', '/5'),
  selfReportedMood('Mood', '/5'),
  selfReportedStress('Stress', '/5');

  const HealthMetric(this.label, this.unit);

  final String label;
  final String unit;

  double? valueFrom(HealthSummary summary) => switch (this) {
    HealthMetric.hrv => summary.hrvMs,
    HealthMetric.restingHeartRate => summary.rhrBpm,
    HealthMetric.averageHeartRate => summary.avgHeartRateBpm,
    HealthMetric.respiratoryRate => summary.respiratoryRateBrpm,
    HealthMetric.bloodOxygen => summary.bloodOxygenPercent,
    HealthMetric.sleep => summary.sleepHours,
    HealthMetric.steps => summary.steps?.toDouble(),
    HealthMetric.distance =>
      summary.distanceMeters == null ? null : summary.distanceMeters! / 1000,
    HealthMetric.exerciseTime => summary.exerciseMinutes,
    HealthMetric.activeEnergy => summary.activeCalories,
    HealthMetric.totalEnergy => summary.totalCalories,
    HealthMetric.selfReportedEnergy ||
    HealthMetric.selfReportedMood ||
    HealthMetric.selfReportedStress => null,
  };
}
