import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:kynos/core/theme/theme.dart';
import 'package:kynos/domain/entities/health_summary.dart';
import 'package:kynos/shared/widgets/metric_tile.dart';

/// Two-column grid of today's health metrics.
class HealthMetricsGrid extends StatelessWidget {
  const HealthMetricsGrid({
    super.key,
    required this.summary,
    this.isLoading = false,
  });

  final HealthSummary? summary;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final kynos = context.kynosTheme;
    final hasRunToday = (summary?.runningWorkoutCount ?? 0) > 0;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: MetricTile(
                label: 'Recovery',
                value: isLoading ? null : _round(summary?.hrvMs),
                unit: 'ms',
                accentColor: kynos.exercise,
              ),
            ),
            const Gap(Spacing.sm),
            Expanded(
              child: MetricTile(
                label: 'Resting pulse',
                value: isLoading ? null : _round(summary?.rhrBpm),
                unit: 'bpm',
                accentColor: kynos.move,
              ),
            ),
          ],
        ),
        const Gap(Spacing.sm),
        Row(
          children: [
            Expanded(
              child: MetricTile(
                label: 'Sleep',
                value: isLoading ? null : _fixed(summary?.sleepHours, 1),
                unit: 'h',
                accentColor: kynos.stand,
              ),
            ),
            const Gap(Spacing.sm),
            Expanded(
              child: MetricTile(
                label: 'SpO2',
                value: isLoading ? null : _fixed(summary?.bloodOxygenPercent, 1),
                unit: '%',
                accentColor: kynos.exercise,
              ),
            ),
          ],
        ),
        const Gap(Spacing.sm),
        Row(
          children: [
            Expanded(
              child: MetricTile(
                label: hasRunToday ? 'Run distance' : 'Active energy',
                value: isLoading
                    ? null
                    : hasRunToday
                        ? _fixed(_toKm(summary?.runningWorkoutDistanceMeters), 2)
                        : _round(summary?.activeCalories),
                unit: hasRunToday ? 'km' : 'kcal',
                accentColor: kynos.stand,
              ),
            ),
            const Gap(Spacing.sm),
            Expanded(
              child: MetricTile(
                label: hasRunToday ? 'Active energy' : 'Exercise time',
                value: isLoading
                    ? null
                    : hasRunToday
                        ? _round(summary?.activeCalories)
                        : summary?.exerciseMinutes == null
                            ? summary?.steps?.toString()
                            : _round(summary?.exerciseMinutes),
                unit: hasRunToday
                    ? 'kcal'
                    : summary?.exerciseMinutes == null
                        ? null
                        : 'min',
                accentColor: kynos.energy,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

String? _round(double? value) => value == null ? '—' : value.round().toString();

String? _fixed(double? value, int digits) =>
    value == null ? '—' : value.toStringAsFixed(digits);

double? _toKm(double? meters) => meters == null ? null : meters / 1000;
