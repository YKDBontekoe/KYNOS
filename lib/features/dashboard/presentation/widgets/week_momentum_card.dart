import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:kynos/core/theme/spacing.dart' as tokens;
import 'package:kynos/core/theme/theme.dart' hide Radius;
import 'package:kynos/domain/utils/weekly_momentum.dart';
import 'package:kynos/shared/widgets/kynos_card.dart';
import 'package:kynos/shared/widgets/metric_tile.dart';

/// Weekly snapshot with week-over-week deltas and distance goal progress.
class WeekMomentumCard extends StatelessWidget {
  const WeekMomentumCard({
    super.key,
    required this.momentum,
    this.isLoading = false,
  });

  final WeeklyMomentum? momentum;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final kynos = context.kynosTheme;
    final m = momentum;

    return KynosCard(
      padding: const EdgeInsets.all(tokens.Spacing.md),
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
          const Gap(tokens.Spacing.sm),
          if (isLoading)
            const LinearProgressIndicator()
          else
            ClipRRect(
              borderRadius: BorderRadius.circular(tokens.Radius.sm),
              child: LinearProgressIndicator(
                value: m?.distanceGoalProgress ?? 0,
                minHeight: 8,
                backgroundColor: kynos.separator,
                valueColor: AlwaysStoppedAnimation(kynos.stand),
              ),
            ),
          const Gap(tokens.Spacing.md),
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
              const Gap(tokens.Spacing.sm),
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
              const Gap(tokens.Spacing.sm),
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
            ],
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
