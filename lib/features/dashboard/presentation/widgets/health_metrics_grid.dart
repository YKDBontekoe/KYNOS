import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:kynos/core/theme/theme.dart';
import 'package:kynos/domain/entities/dashboard/dashboard_summary.dart';
import 'package:kynos/domain/entities/health_summary.dart';
import 'package:kynos/domain/utils/metric_trends.dart';
import 'package:kynos/features/dashboard/presentation/widgets/metric_detail_sheet.dart';
import 'package:kynos/shared/widgets/metric_tile.dart';

/// Two-column grid of today's health metrics with delta sublabels.
class HealthMetricsGrid extends StatelessWidget {
  const HealthMetricsGrid({
    super.key,
    required this.summary,
    required this.dashboardSummary,
    this.isLoading = false,
    this.onViewTraining,
    this.onAskCoach,
  });

  final HealthSummary? summary;
  final DashboardSummary? dashboardSummary;
  final bool isLoading;
  final VoidCallback? onViewTraining;
  final void Function(String seedMessage)? onAskCoach;

  @override
  Widget build(BuildContext context) {
    final kynos = context.kynosTheme;
    final hasRunToday = (summary?.runningWorkoutCount ?? 0) > 0;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _metric(
                context,
                kynos: kynos,
                label: 'Recovery',
                value: isLoading ? null : _round(summary?.hrvMs),
                unit: 'ms',
                accentColor: kynos.exercise,
                today: summary?.hrvMs,
                selector: (s) => s.hrvMs,
                higherIsBetter: true,
                digits: 0,
                metricKey: MetricDetailKey.hrv,
              ),
            ),
            const Gap(Spacing.sm),
            Expanded(
              child: _metric(
                context,
                kynos: kynos,
                label: 'Resting pulse',
                value: isLoading ? null : _round(summary?.rhrBpm),
                unit: 'bpm',
                accentColor: kynos.move,
                today: summary?.rhrBpm,
                selector: (s) => s.rhrBpm,
                higherIsBetter: false,
                digits: 0,
                metricKey: MetricDetailKey.rhr,
              ),
            ),
          ],
        ),
        const Gap(Spacing.sm),
        Row(
          children: [
            Expanded(
              child: _metric(
                context,
                kynos: kynos,
                label: 'Sleep',
                value: isLoading ? null : _fixed(summary?.sleepHours, 1),
                unit: 'h',
                accentColor: kynos.stand,
                today: summary?.sleepHours,
                selector: (s) => s.sleepHours,
                higherIsBetter: true,
                digits: 1,
                metricKey: MetricDetailKey.sleep,
              ),
            ),
            const Gap(Spacing.sm),
            Expanded(
              child: _metric(
                context,
                kynos: kynos,
                label: 'SpO2',
                value: isLoading ? null : _fixed(summary?.bloodOxygenPercent, 1),
                unit: '%',
                accentColor: kynos.exercise,
                today: summary?.bloodOxygenPercent,
                selector: (s) => s.bloodOxygenPercent,
                higherIsBetter: true,
                digits: 1,
                metricKey: MetricDetailKey.spo2,
              ),
            ),
          ],
        ),
        const Gap(Spacing.sm),
        Row(
          children: [
            Expanded(
              child: _metric(
                context,
                kynos: kynos,
                label: hasRunToday ? 'Run distance' : 'Active energy',
                value: isLoading
                    ? null
                    : hasRunToday
                    ? _fixed(_toKm(summary?.runningWorkoutDistanceMeters), 2)
                    : _round(summary?.activeCalories),
                unit: hasRunToday ? 'km' : 'kcal',
                accentColor: kynos.stand,
                today: hasRunToday
                    ? _toKm(summary?.runningWorkoutDistanceMeters)
                    : summary?.activeCalories,
                selector: (s) => hasRunToday
                    ? _toKm(s.runningWorkoutDistanceMeters)
                    : s.activeCalories,
                higherIsBetter: true,
                digits: hasRunToday ? 2 : 0,
                metricKey: hasRunToday
                    ? MetricDetailKey.distance
                    : MetricDetailKey.activeCalories,
              ),
            ),
            const Gap(Spacing.sm),
            Expanded(
              child: _metric(
                context,
                kynos: kynos,
                label: hasRunToday ? 'Active energy' : 'Exercise time',
                value: isLoading
                    ? null
                    : hasRunToday
                    ? _round(summary?.activeCalories)
                    : _exerciseOrStepsValue(summary),
                unit: hasRunToday
                    ? 'kcal'
                    : summary?.exerciseMinutes == null
                    ? null
                    : 'min',
                accentColor: kynos.energy,
                today: hasRunToday
                    ? summary?.activeCalories
                    : summary?.exerciseMinutes?.toDouble(),
                selector: (s) => hasRunToday
                    ? s.activeCalories
                    : s.exerciseMinutes?.toDouble(),
                higherIsBetter: true,
                digits: 0,
                metricKey: hasRunToday
                    ? MetricDetailKey.activeCalories
                    : MetricDetailKey.exercise,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _metric(
    BuildContext context, {
    required KynosThemeExtension kynos,
    required String label,
    required String? value,
    required String? unit,
    required Color accentColor,
    required double? today,
    required double? Function(HealthSummary) selector,
    required bool higherIsBetter,
    required int digits,
    required MetricDetailKey metricKey,
  }) {
    final vsYesterday = dashboardSummary?.deltaVsYesterday(
      today,
      selector,
      higherIsBetter: higherIsBetter,
    );
    final vs7Day = dashboardSummary?.deltaVs7DayAvg(
      today,
      selector,
      higherIsBetter: higherIsBetter,
    );
    final sublabel = formatMetricDeltaSublabel(
      vsYesterday: vsYesterday,
      vs7DayAvg: vs7Day,
      unit: unit ?? '',
      digits: digits,
    );
    final sublabelColor = vsYesterday != null
        ? (isDeltaPositive(vsYesterday) ? kynos.exercise : kynos.move)
        : (vs7Day != null && isDeltaPositive(vs7Day)
              ? kynos.exercise
              : kynos.move);

    return MetricTile(
      label: label,
      value: value,
      unit: unit,
      accentColor: accentColor,
      sublabel: sublabel,
      sublabelColor: sublabel != null ? sublabelColor : null,
      onTap: dashboardSummary == null
          ? null
          : () => showMetricDetailSheet(
              context,
              metricKey: metricKey,
              history: dashboardSummary!.history7Day,
              onViewTraining: onViewTraining,
              onAskCoach: onAskCoach,
            ),
    );
  }
}

String _round(double? value) => value == null ? '—' : value.round().toString();

String _fixed(double? value, int digits) =>
    value == null ? '—' : value.toStringAsFixed(digits);

String _exerciseOrStepsValue(HealthSummary? summary) {
  if (summary?.exerciseMinutes != null) {
    return _round(summary!.exerciseMinutes);
  }
  if (summary?.steps != null) {
    return summary!.steps!.toString();
  }
  return '—';
}

double? _toKm(double? meters) => meters == null ? null : meters / 1000;
