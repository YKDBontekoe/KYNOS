import 'package:kynos/core/constants/app_constants.dart';
import 'package:kynos/domain/entities/health_summary.dart';

/// Acute:chronic workload ratio from daily running distance.
///
/// Acute = mean daily km over last 7 days; chronic = mean over last 28 days.
double? computeAcwr(List<HealthSummary> history) {
  if (history.length < 7) return null;

  final sorted = List<HealthSummary>.from(history)
    ..sort((a, b) => b.date.compareTo(a.date));

  double dailyKm(HealthSummary s) =>
      (s.runningWorkoutDistanceMeters ?? 0) / 1000;

  final acuteDays = sorted.take(7).toList();
  final chronicDays = sorted.take(28).toList();

  final acuteLoad =
      acuteDays.map(dailyKm).reduce((a, b) => a + b) / acuteDays.length;
  final chronicLoad =
      chronicDays.map(dailyKm).reduce((a, b) => a + b) / chronicDays.length;

  if (chronicLoad <= 0) return null;
  return acuteLoad / chronicLoad;
}

bool isAcwrElevated(double? acwr) =>
    acwr != null && acwr > AppConstants.acwrSafeMax;

String acwrRiskLabel(double acwr) {
  if (acwr > 1.5) return 'High injury risk — reduce volume this week.';
  if (acwr > AppConstants.acwrSafeMax) {
    return 'Elevated load — keep intensity easy for 2–3 days.';
  }
  return 'Training load is within a safe range.';
}
