import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:kynos/core/theme/app_theme.dart';
import 'package:kynos/core/theme/spacing.dart' as tokens;
import 'package:kynos/domain/entities/health_summary.dart';
import 'package:kynos/domain/utils/running_distance.dart';
import 'package:kynos/shared/widgets/metric_tile.dart';

/// 2×2 grid of weekly training metrics.
class WeeklyStatsGrid extends StatelessWidget {
  const WeeklyStatsGrid({super.key, required this.history});

  final List<HealthSummary> history;

  @override
  Widget build(BuildContext context) {
    final cutoff = DateTime.now().subtract(const Duration(days: 7));
    final week = history.where((s) => s.date.isAfter(cutoff)).toList();

    final totalKm = week.map(dailyRunningDistanceKm).fold(0.0, (a, b) => a + b);

    final runCount = week
        .map((s) => s.runningWorkoutCount ?? 0)
        .fold(0, (a, b) => a + b);

    final hrvValues = week
        .where((s) => s.hrvMs != null)
        .map((s) => s.hrvMs!)
        .toList();
    final avgHrv = hrvValues.isEmpty
        ? null
        : hrvValues.fold(0.0, (a, b) => a + b) / hrvValues.length;

    final activeKcal = week
        .map((s) => s.activeCalories ?? 0)
        .fold(0.0, (a, b) => a + b);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: MetricTile(
                label: 'Distance',
                value: totalKm > 0 ? totalKm.toStringAsFixed(1) : '—',
                unit: 'km',
                accentColor: AppTheme.stand,
              ),
            ),
            const Gap(tokens.Spacing.sm),
            Expanded(
              child: MetricTile(
                label: 'Runs',
                value: runCount > 0 ? '$runCount' : '—',
                unit: null,
                accentColor: AppTheme.exercise,
              ),
            ),
          ],
        ),
        const Gap(tokens.Spacing.sm),
        Row(
          children: [
            Expanded(
              child: MetricTile(
                label: 'Avg recovery',
                value: avgHrv == null ? '—' : '${avgHrv.round()}',
                unit: 'ms',
                accentColor: AppTheme.purple,
              ),
            ),
            const Gap(tokens.Spacing.sm),
            Expanded(
              child: MetricTile(
                label: 'Active kcal',
                value: activeKcal > 0 ? '${activeKcal.round()}' : '—',
                unit: 'kcal',
                accentColor: AppTheme.energy,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
