import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:kynos/core/theme/spacing.dart' as tokens;
import 'package:kynos/core/theme/theme.dart';
import 'package:kynos/domain/utils/pace_format.dart';
import 'package:kynos/domain/utils/run_route_analytics.dart';
import 'package:kynos/shared/widgets/charts/chart_placeholder.dart';
import 'package:kynos/shared/widgets/kynos_card.dart';

/// Kilometer split list with proportional pace bars.
class RunSplitList extends StatelessWidget {
  const RunSplitList({
    super.key,
    required this.analytics,
  });

  final RunRouteAnalytics analytics;

  @override
  Widget build(BuildContext context) {
    final splits = analytics.kilometerSplits;
    if (splits.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: tokens.Spacing.md),
        child: KynosCard(
          child: ChartPlaceholder(
            label: 'Kilometer splits need timestamped GPS data',
          ),
        ),
      );
    }

    final avgPace =
        splits.map((s) => s.paceSecondsPerKm).reduce((a, b) => a + b) /
            splits.length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: tokens.Spacing.md),
      child: KynosCard(
        child: Column(
          children: [
            for (var i = 0; i < splits.length; i++) ...[
              if (i > 0) const Gap(tokens.Spacing.sm),
              _SplitRow(
                split: splits[i],
                avgPaceSecondsPerKm: avgPace,
                isFastest: analytics.fastestSplitIndex == i,
                isSlowest: analytics.slowestSplitIndex == i,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SplitRow extends StatelessWidget {
  const _SplitRow({
    required this.split,
    required this.avgPaceSecondsPerKm,
    required this.isFastest,
    required this.isSlowest,
  });

  final KilometerSplit split;
  final double avgPaceSecondsPerKm;
  final bool isFastest;
  final bool isSlowest;

  @override
  Widget build(BuildContext context) {
    final kynos = context.kynosTheme;
    final theme = Theme.of(context);
    final paceLabel = formatPacePerKm(split.paceSecondsPerKm);
    final barFraction =
        (split.paceSecondsPerKm / avgPaceSecondsPerKm).clamp(0.55, 1.45);
    final barColor = isFastest
        ? kynos.exercise
        : isSlowest
            ? kynos.energy
            : kynos.stand;

    return Semantics(
      label: 'Kilometer ${split.kilometer}, pace $paceLabel',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Km ${split.kilometer}',
                style: theme.textTheme.labelLarge,
              ),
              const Spacer(),
              Text(
                paceLabel,
                style: kynos.metricValueStyle.copyWith(fontSize: 14),
              ),
            ],
          ),
          const Gap(tokens.Spacing.xs),
          ClipRRect(
            borderRadius: BorderRadius.circular(tokens.Radius.sm),
            child: LinearProgressIndicator(
              value: barFraction / 1.45,
              minHeight: 8,
              backgroundColor: kynos.separator.withValues(alpha: 0.35),
              color: barColor,
            ),
          ),
        ],
      ),
    );
  }
}
