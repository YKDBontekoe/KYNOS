import 'package:kynos/domain/entities/health_summary.dart';

const _hrvWeight = 0.35;
const _rhrWeight = 0.25;
const _sleepWeight = 0.25;
const _spo2Weight = 0.15;

bool _hasReadinessMetrics(HealthSummary summary) =>
    summary.hrvMs != null ||
    summary.rhrBpm != null ||
    summary.sleepHours != null ||
    summary.bloodOxygenPercent != null;

/// Composite recovery readiness score (0–100) from available daily metrics.
///
/// Null metrics are excluded from the weighted average rather than treated as
/// unhealthy sentinel values.
double readinessScore(HealthSummary? summary) {
  if (summary == null || !_hasReadinessMetrics(summary)) return 0;

  var weighted = 0.0;
  var totalWeight = 0.0;

  if (summary.hrvMs != null) {
    final hrvScore = (summary.hrvMs!.clamp(20, 110) - 20) / 90;
    weighted += hrvScore * _hrvWeight;
    totalWeight += _hrvWeight;
  }
  if (summary.rhrBpm != null) {
    final rhrScore = 1 - ((summary.rhrBpm!.clamp(45, 90) - 45) / 45);
    weighted += rhrScore * _rhrWeight;
    totalWeight += _rhrWeight;
  }
  if (summary.sleepHours != null) {
    final sleepScore = (summary.sleepHours!.clamp(4, 9) - 4) / 5;
    weighted += sleepScore * _sleepWeight;
    totalWeight += _sleepWeight;
  }
  if (summary.bloodOxygenPercent != null) {
    final spo2Score = (summary.bloodOxygenPercent!.clamp(90, 100) - 90) / 10;
    weighted += spo2Score * _spo2Weight;
    totalWeight += _spo2Weight;
  }

  if (totalWeight == 0) return 0;
  return ((weighted / totalWeight) * 100).clamp(0, 100);
}

/// Readiness score for quest generation when summary may be absent or sparse.
double readinessScoreOrDefault(HealthSummary? summary, {double fallback = 60}) {
  if (summary == null || !_hasReadinessMetrics(summary)) return fallback;
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
