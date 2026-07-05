import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:kynos/core/theme/theme.dart';
import 'package:kynos/domain/entities/health_summary.dart';
import 'package:kynos/shared/widgets/metric_tile.dart';

/// Compact single-row weekly snapshot for the Today tab.
class WeeklySnapshotRow extends StatelessWidget {
  const WeeklySnapshotRow({
    super.key,
    required this.history,
    this.isLoading = false,
  });

  final List<HealthSummary> history;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final kynos = context.kynosTheme;
    final cutoff = DateTime.now().subtract(const Duration(days: 7));
    final week = history.where((s) => s.date.isAfter(cutoff)).toList();

    final totalKm = week
        .map(
          (s) =>
              (s.runningWorkoutDistanceMeters ?? s.distanceMeters ?? 0) / 1000,
        )
        .fold(0.0, (a, b) => a + b);

    final runCount = week
        .map((s) => s.runningWorkoutCount ?? 0)
        .fold(0, (a, b) => a + b);

    final activeKcal = week
        .map((s) => s.activeCalories ?? 0)
        .fold(0.0, (a, b) => a + b);

    return Row(
      children: [
        Expanded(
          child: MetricTile(
            label: 'Week distance',
            value: isLoading
                ? null
                : totalKm > 0
                    ? totalKm.toStringAsFixed(1)
                    : '—',
            unit: 'km',
            accentColor: kynos.stand,
          ),
        ),
        const Gap(Spacing.sm),
        Expanded(
          child: MetricTile(
            label: 'Runs',
            value: isLoading ? null : runCount > 0 ? '$runCount' : '—',
            accentColor: kynos.exercise,
          ),
        ),
        const Gap(Spacing.sm),
        Expanded(
          child: MetricTile(
            label: 'Active kcal',
            value: isLoading
                ? null
                : activeKcal > 0
                    ? '${activeKcal.round()}'
                    : '—',
            unit: 'kcal',
            accentColor: kynos.energy,
          ),
        ),
      ],
    );
  }
}
