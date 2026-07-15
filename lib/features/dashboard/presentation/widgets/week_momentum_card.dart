import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:kynos/core/theme/spacing.dart' as tokens;
import 'package:kynos/core/theme/theme.dart' hide Radius;
import 'package:kynos/domain/utils/weekly_momentum.dart';
import 'package:kynos/shared/widgets/animated_progress_bar.dart';
import 'package:kynos/shared/widgets/kynos_card.dart';
import 'package:kynos/shared/widgets/kynos_chip.dart';
import 'package:kynos/shared/widgets/kynos_empty_cta.dart';
import 'package:kynos/shared/widgets/kynos_loading_line.dart';
import 'package:kynos/shared/widgets/metric_tile.dart';

/// Weekly snapshot with week-over-week deltas and distance goal progress.
class WeekMomentumCard extends StatelessWidget {
  const WeekMomentumCard({
    super.key,
    required this.momentum,
    this.isLoading = false,
    this.onImportRun,
    this.onAskCoach,
  });

  final WeeklyMomentum? momentum;
  final bool isLoading;
  final VoidCallback? onImportRun;
  final VoidCallback? onAskCoach;

  @override
  Widget build(BuildContext context) {
    final kynos = context.kynosTheme;
    final m = momentum;
    final hasNoActivity = !isLoading &&
        (m == null || (m.thisWeekRuns == 0 && m.thisWeekDistanceKm <= 0));

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
              if (!isLoading && m != null && !hasNoActivity)
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
              value: hasNoActivity ? 0 : (m?.distanceGoalProgress ?? 0),
              minHeight: 10,
              backgroundColor: kynos.separator,
              valueColor: kynos.stand,
            ),
          if (hasNoActivity) ...[
            const Gap(tokens.Spacing.md),
            if (onImportRun != null)
              KynosEmptyCta(
                message:
                    'Log or import a run to start tracking your weekly distance '
                    'goal of ${m?.distanceGoalKm.toStringAsFixed(0) ?? '30'} km.',
                primaryLabel: 'Import a run',
                icon: Icons.upload_file_outlined,
                onPrimary: onImportRun!,
                secondaryLabel:
                    onAskCoach == null ? null : 'Ask Coach for a plan',
                onSecondary: onAskCoach,
              )
            else
              Text(
                'Connect health data or import a run to track weekly momentum.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: kynos.secondaryLabel,
                    ),
              ),
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
          // Empty state already exposes Ask Coach via [KynosEmptyCta].
          if (onAskCoach != null && !hasNoActivity) ...[
            const Gap(tokens.Spacing.md),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: onAskCoach,
                icon: const Icon(Icons.auto_awesome_rounded, size: 18),
                label: const Text('Ask Coach for a plan'),
              ),
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
