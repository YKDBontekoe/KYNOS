import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:kynos/core/theme/app_theme.dart';
import 'package:kynos/core/theme/spacing.dart' as tokens;
import 'package:kynos/domain/entities/health_summary.dart';
import 'package:kynos/shared/widgets/metric_tile.dart';

/// Two-column grid of today's health metrics.
class HealthMetricsGrid extends StatelessWidget {
  const HealthMetricsGrid({super.key, required this.summary});

  final HealthSummary? summary;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: MetricTile(
                label: 'Recovery',
                value: _round(summary?.hrvMs),
                unit: 'ms',
                accentColor: AppTheme.exercise,
              ),
            ),
            const Gap(tokens.Spacing.sm),
            Expanded(
              child: MetricTile(
                label: 'Resting pulse',
                value: _round(summary?.rhrBpm),
                unit: 'bpm',
                accentColor: AppTheme.move,
              ),
            ),
          ],
        ),
        const Gap(tokens.Spacing.sm),
        Row(
          children: [
            Expanded(
              child: MetricTile(
                label: 'Sleep',
                value: _fixed(summary?.sleepHours, 1),
                unit: 'h',
                accentColor: AppTheme.stand,
              ),
            ),
            const Gap(tokens.Spacing.sm),
            Expanded(
              child: MetricTile(
                label: 'SpO2',
                value: _fixed(summary?.bloodOxygenPercent, 1),
                unit: '%',
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
                label: 'Distance',
                value: _fixed(_toKm(summary?.distanceMeters), 2),
                unit: 'km',
                accentColor: AppTheme.stand,
              ),
            ),
            const Gap(tokens.Spacing.sm),
            Expanded(
              child: MetricTile(
                label: 'Steps',
                value: summary?.steps?.toString() ?? '—',
                unit: null,
                accentColor: AppTheme.energy,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

String _round(double? value) => value == null ? '—' : value.round().toString();

String _fixed(double? value, int digits) =>
    value == null ? '—' : value.toStringAsFixed(digits);

double? _toKm(double? meters) => meters == null ? null : meters / 1000;
