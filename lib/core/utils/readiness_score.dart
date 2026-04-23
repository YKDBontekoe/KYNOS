import 'package:kynos/domain/entities/health_summary.dart';

/// Computes a 0–100 readiness score from biometric data.
///
/// Weights: HRV 35 %, RHR 25 %, sleep 25 %, SpO2 15 %.
/// Callers supply explicit fallback values for each metric so that the
/// score reflects domain-appropriate defaults (e.g. pessimistic defaults
/// for today's insight vs. neutral defaults for XP/quest generation).
abstract final class ReadinessScore {
  static double compute(
    HealthSummary? summary, {
    double fallbackHrvMs = 40,
    double fallbackRhrBpm = 65,
    double fallbackSleepHours = 7,
    double fallbackBloodOxygenPercent = 97,
  }) {
    if (summary == null) {
      return _score(
        fallbackHrvMs,
        fallbackRhrBpm,
        fallbackSleepHours,
        fallbackBloodOxygenPercent,
      );
    }
    return _score(
      summary.hrvMs ?? fallbackHrvMs,
      summary.rhrBpm ?? fallbackRhrBpm,
      summary.sleepHours ?? fallbackSleepHours,
      summary.bloodOxygenPercent ?? fallbackBloodOxygenPercent,
    );
  }

  static double _score(
    double hrv,
    double rhr,
    double sleep,
    double spo2,
  ) {
    final hrvScore = (hrv.clamp(20, 110) - 20) / 90;
    final rhrScore = 1 - ((rhr.clamp(45, 90) - 45) / 45);
    final sleepScore = (sleep.clamp(4, 9) - 4) / 5;
    final spo2Score = (spo2.clamp(90, 100) - 90) / 10;
    return ((hrvScore * 0.35 + rhrScore * 0.25 + sleepScore * 0.25 + spo2Score * 0.15) * 100)
        .clamp(0, 100);
  }
}
