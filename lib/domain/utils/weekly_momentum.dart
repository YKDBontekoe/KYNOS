import 'package:kynos/core/constants/app_constants.dart';
import 'package:kynos/domain/entities/health_summary.dart';
import 'package:kynos/domain/utils/running_distance.dart';

/// Week-over-week training momentum derived from health history.
class WeeklyMomentum {
  const WeeklyMomentum({
    required this.thisWeekDistanceKm,
    required this.thisWeekRuns,
    required this.thisWeekActiveKcal,
    this.distanceDeltaPct,
    this.runsDeltaPct,
    this.kcalDeltaPct,
    required this.distanceGoalKm,
    required this.distanceGoalProgress,
  });

  final double thisWeekDistanceKm;
  final int thisWeekRuns;
  final double thisWeekActiveKcal;
  final double? distanceDeltaPct;
  final double? runsDeltaPct;
  final double? kcalDeltaPct;
  final double distanceGoalKm;
  final double distanceGoalProgress;
}

double _weekDistanceKm(List<HealthSummary> week) => week
    .map(dailyRunningDistanceKm)
    .fold(0.0, (a, b) => a + b);

int _weekRuns(List<HealthSummary> week) => week
    .map((s) => s.runningWorkoutCount ?? 0)
    .fold(0, (a, b) => a + b);

double _weekKcal(List<HealthSummary> week) => week
    .map((s) => s.activeCalories ?? 0)
    .fold(0.0, (a, b) => a + b);

double? _pctDelta(double current, double previous) {
  if (previous <= 0) return current > 0 ? 100 : null;
  return ((current - previous) / previous) * 100;
}

List<HealthSummary> _weekSlice(List<HealthSummary> history, int daysAgoStart) {
  final now = DateTime.now();
  final start = now.subtract(Duration(days: daysAgoStart));
  final end = now.subtract(Duration(days: daysAgoStart - 7));
  return history
      .where((s) => s.date.isAfter(start) && !s.date.isAfter(end))
      .toList();
}

/// Builds this-week stats with week-over-week deltas and goal progress.
WeeklyMomentum computeWeeklyMomentum(List<HealthSummary> history) {
  final thisWeek = _weekSlice(history, 7);
  final lastWeek = _weekSlice(history, 14);

  final distanceKm = _weekDistanceKm(thisWeek);
  final runs = _weekRuns(thisWeek);
  final kcal = _weekKcal(thisWeek);

  final prevDistance = _weekDistanceKm(lastWeek);
  final prevRuns = _weekRuns(lastWeek);
  final prevKcal = _weekKcal(lastWeek);

  final goalKm = AppConstants.weeklyDistanceGoalKm;
  final progress = goalKm > 0 ? (distanceKm / goalKm).clamp(0.0, 1.0) : 0.0;

  return WeeklyMomentum(
    thisWeekDistanceKm: distanceKm,
    thisWeekRuns: runs,
    thisWeekActiveKcal: kcal,
    distanceDeltaPct: _pctDelta(distanceKm, prevDistance),
    runsDeltaPct: _pctDelta(runs.toDouble(), prevRuns.toDouble()),
    kcalDeltaPct: _pctDelta(kcal, prevKcal),
    distanceGoalKm: goalKm,
    distanceGoalProgress: progress,
  );
}

/// Formats a week-over-week badge, e.g. "+12%".
String? formatWowBadge(double? pct) {
  if (pct == null || pct.abs() < 0.5) return null;
  final sign = pct > 0 ? '+' : '';
  return '$sign${pct.round()}%';
}
