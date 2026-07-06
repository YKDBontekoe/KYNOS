import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:kynos/core/theme/spacing.dart' as tokens;
import 'package:kynos/core/theme/theme.dart' hide Radius;
import 'package:kynos/domain/utils/weekly_momentum.dart';
import 'package:kynos/shared/widgets/animated_progress_bar.dart';
import 'package:kynos/shared/widgets/kynos_card.dart';
import 'package:kynos/shared/widgets/kynos_chip.dart';
import 'package:kynos/shared/widgets/kynos_loading_line.dart';
import 'package:kynos/shared/widgets/metric_tile.dart';

/// Weekly snapshot with week-over-week deltas and distance goal progress.
class WeekMomentumCard extends StatelessWidget {
  const WeekMomentumCard({
    super.key,
    required this.momentum,
    this.isLoading = false,
    this.onImportRun,
  });

  final WeeklyMomentum? momentum;
  final bool isLoading;
  final VoidCallback? onImportRun;

  @override
  Widget build(BuildContext context) {
    final kynos = context.kynosTheme;
    final m = momentum;
    final hasNoData = !isLoading && m == null;

    return KynosCard(
      padding: const EdgeInsets.all(tokens.Spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Weekly goal',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
              if (!isLoading && m != null)
                Text(
                  '${m.thisWeekDistanceKm.toStringAsFixed(1)} / ${m.distanceGoalKm.toStringAsFixed(0)} km',
                  style: kynos.metricValueStyle.copyWith(fontSize: 14),
                ),
            ],
          ),
          const Gap(tokens.Spacing.md),
          if (isLoading)
            const KynosLoadingLine(height: 10, widthFactor: 1)
          else
            AnimatedProgressBar(
              value: m?.distanceGoalProgress ?? 0,
              minHeight: 10,
              backgroundColor: kynos.separator,
              valueColor: kynos.stand,
            ),
          if (hasNoData) ...[
            const Gap(tokens.Spacing.md),
            Text(
              'Connect health data or import a run to track weekly momentum.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: kynos.secondaryLabel,
                  ),
            ),
            if (onImportRun != null) ...[
              const Gap(tokens.Spacing.sm),
              TextButton(onPressed: onImportRun, child: const Text('Import a run')),
            ],
          ] else ...[
            const Gap(tokens.Spacing.lg),
            Row(
              children: [
                Expanded(
                  child: MetricTile(
                    label: 'Week distance',
                    value: isLoading
                        ? null
                        : m != null && m.thisWeekDistanceKm > 0
                            ? m.thisWeekDistanceKm.toStringAsFixed(1)
                            : '—',
                    unit: 'km',
                    accentColor: kynos.stand,
                    sublabel: formatWowBadge(m?.distanceDeltaPct),
                    sublabelColor: _wowColor(kynos, m?.distanceDeltaPct),
                  ),
                ),
                const Gap(tokens.Spacing.md),
                Expanded(
                  child: MetricTile(
                    label: 'Runs',
                    value: isLoading
                        ? null
                        : m != null && m.thisWeekRuns > 0
                            ? '${m.thisWeekRuns}'
                            : '—',
                    accentColor: kynos.exercise,
                    sublabel: formatWowBadge(m?.runsDeltaPct),
                    sublabelColor: _wowColor(kynos, m?.runsDeltaPct),
                  ),
                ),
              ],
            ),
            const Gap(tokens.Spacing.md),
            Row(
              children: [
                Expanded(
                  child: MetricTile(
                    label: 'Active kcal',
                    value: isLoading
                        ? null
                        : m != null && m.thisWeekActiveKcal > 0
                            ? '${m.thisWeekActiveKcal.round()}'
                            : '—',
                    unit: 'kcal',
                    accentColor: kynos.energy,
                    sublabel: formatWowBadge(m?.kcalDeltaPct),
                    sublabelColor: _wowColor(kynos, m?.kcalDeltaPct),
                  ),
                ),
                const Gap(tokens.Spacing.md),
                Expanded(
                  child: _wowSummaryTile(context, kynos, m, isLoading),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _wowSummaryTile(
    BuildContext context,
    KynosThemeExtension kynos,
    WeeklyMomentum? m,
    bool isLoading,
  ) {
    if (isLoading || m == null) {
      return MetricTile(
        label: 'Week trend',
        value: isLoading ? null : '—',
        accentColor: kynos.purple,
      );
    }

    final bestDelta = [
      m.distanceDeltaPct,
      m.runsDeltaPct,
      m.kcalDeltaPct,
    ].whereType<double>().fold<double?>(
      null,
      (best, pct) =>
          best == null || pct.abs() > best.abs() ? pct : best,
    );

    if (bestDelta == null) {
      return MetricTile(
        label: 'Week trend',
        value: '—',
        accentColor: kynos.purple,
      );
    }

    return KynosCard(
      padding: const EdgeInsets.all(tokens.Spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Week trend',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const Gap(tokens.Spacing.sm),
          KynosChip.accent(
            label: formatWowBadge(bestDelta) ?? '—',
            color: _wowColor(kynos, bestDelta) ?? kynos.purple,
          ),
        ],
      ),
    );
  }

  Color? _wowColor(KynosThemeExtension kynos, double? pct) {
    if (pct == null || pct.abs() < 0.5) return null;
    return pct > 0 ? kynos.exercise : kynos.move;
  }
}
