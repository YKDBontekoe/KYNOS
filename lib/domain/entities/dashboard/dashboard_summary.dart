import 'package:kynos/domain/entities/gamification/runner_character.dart';
import 'package:kynos/domain/entities/health_summary.dart';
import 'package:kynos/domain/utils/metric_trends.dart';
import 'package:kynos/domain/utils/weekly_momentum.dart';

/// Pre-computed dashboard aggregates for the Today tab.
class DashboardSummary {
  const DashboardSummary({
    required this.runStreak,
    required this.weeklyMomentum,
    required this.personalBestCallouts,
    this.streakNudge,
    this.character,
    this.yesterday,
    this.history7Day = const [],
    this.isGaitCalibrated = false,
    this.gaitCoefficients = const (b0: null, b1: null, b2: null),
    this.gaitCalibratedAt,
  });

  final int runStreak;
  final WeeklyMomentum weeklyMomentum;
  final List<String> personalBestCallouts;
  final String? streakNudge;
  final RunnerCharacter? character;
  final HealthSummary? yesterday;
  final List<HealthSummary> history7Day;
  final bool isGaitCalibrated;
  final ({double? b0, double? b1, double? b2}) gaitCoefficients;
  final DateTime? gaitCalibratedAt;

  /// 7-day rolling average for a numeric field on [summary].
  double? avg7Day(double? Function(HealthSummary) selector) {
    return rollingAverage(history7Day.map(selector));
  }

  MetricDelta? deltaVsYesterday(
    double? today,
    double? Function(HealthSummary) selector, {
    required bool higherIsBetter,
  }) {
    return computeMetricDelta(
      today: today,
      baseline: yesterday == null ? null : selector(yesterday!),
      higherIsBetter: higherIsBetter,
    );
  }

  MetricDelta? deltaVs7DayAvg(
    double? today,
    double? Function(HealthSummary) selector, {
    required bool higherIsBetter,
  }) {
    return computeMetricDelta(
      today: today,
      baseline: avg7Day(selector),
      higherIsBetter: higherIsBetter,
    );
  }
}
