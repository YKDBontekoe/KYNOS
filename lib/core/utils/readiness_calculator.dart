import 'package:kynos/domain/entities/health_summary.dart';

/// Utility to calculate a basic Readiness score (0-100) from a health summary.
int calculateReadiness(HealthSummary? summary) {
  if (summary == null) return 0;

  double score = 50.0; // Baseline

  // Sleep factor (Max +25, Min -20)
  final sleep = summary.sleepHours ?? 0.0;
  if (sleep >= 7.5) {
    score += 25;
  } else if (sleep >= 6.0) {
    score += 10;
  } else if (sleep > 0.0) {
    score -= 20;
  }

  // HRV factor (Max +25, Min -15) - Rough approximation
  final hrv = summary.hrvMs ?? 0.0;
  if (hrv > 60) {
    score += 25;
  } else if (hrv > 40) {
    score += 10;
  } else if (hrv > 0) {
    score -= 15;
  }

  return score.clamp(0, 100).toInt();
}
