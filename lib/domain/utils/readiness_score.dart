import 'package:kynos/domain/entities/health_summary.dart';

/// Composite recovery readiness score (0–100) from daily health metrics.
double readinessScore(HealthSummary? summary) {
  if (summary == null) return 0;

  final hrvScore = ((summary.hrvMs ?? 20).clamp(20, 110) - 20) / 90;
  final rhrScore = 1 - (((summary.rhrBpm ?? 75).clamp(45, 90) - 45) / 45);
  final sleepScore = ((summary.sleepHours ?? 5).clamp(4, 9) - 4) / 5;
  final spo2Score =
      ((summary.bloodOxygenPercent ?? 95).clamp(90, 100) - 90) / 10;

  return ((hrvScore * 0.35 +
              rhrScore * 0.25 +
              sleepScore * 0.25 +
              spo2Score * 0.15) *
          100)
      .clamp(0, 100);
}

/// Readiness score for quest generation when summary may be absent.
double readinessScoreOrDefault(HealthSummary? summary, {double fallback = 60}) {
  if (summary == null) return fallback;
  return readinessScore(summary);
}

/// Human-readable readiness summary for dashboard display.
String readinessSummary(double score) {
  if (score >= 80) {
    return 'Strong recovery. High quality session is supported today.';
  }
  if (score >= 65) {
    return 'Stable recovery. Tempo or aerobic run should feel good.';
  }
  if (score >= 45) return 'Moderate readiness. Keep intensity controlled.';
  return 'Low readiness. Prioritise recovery and easy movement.';
}

/// Shorter readiness summary for insight use-cases.
String readinessSummaryBrief(double score) {
  if (score >= 80) return 'Great readiness. Good day for quality work.';
  if (score >= 65) return 'Solid readiness. Tempo or aerobic work fits.';
  if (score >= 45) return 'Moderate readiness. Keep effort controlled.';
  return 'Low readiness. Prioritise recovery and easy movement.';
}
