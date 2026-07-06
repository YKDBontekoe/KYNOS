import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:kynos/core/theme/spacing.dart' as tokens;
import 'package:kynos/domain/entities/health_summary.dart';
import 'package:kynos/shared/widgets/charts/chart_placeholder.dart';
import 'package:kynos/shared/widgets/charts/hrv_chart.dart';
import 'package:kynos/shared/widgets/charts/load_chart.dart';
import 'package:kynos/shared/widgets/kynos_card.dart';

/// 30-day recovery and training-load trend cards.
class TrendCards extends StatelessWidget {
  const TrendCards({super.key, required this.history});

  final List<HealthSummary> history;

  @override
  Widget build(BuildContext context) {
    final points = history.toList()..sort((a, b) => a.date.compareTo(b.date));

    return Column(
      children: [
        KynosCard(
          child: SizedBox(
            height: 210,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recovery',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Gap(tokens.Spacing.xs),
                Text(
                  'Shows recovery volatility across recent sessions.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const Gap(tokens.Spacing.md),
                Expanded(
                  child: points.isEmpty
                      ? const ChartPlaceholder(label: 'No HRV data yet')
                      : HrvChart(points: points),
                ),
              ],
            ),
          ),
        ),
        const Gap(tokens.Spacing.md),
        KynosCard(
          child: SizedBox(
            height: 210,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Training Load',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Gap(tokens.Spacing.xs),
                Text(
                  'Daily running distance and active calories.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const Gap(tokens.Spacing.md),
                Expanded(
                  child: points.isEmpty
                      ? const ChartPlaceholder(label: 'No run history yet')
                      : LoadChart(points: points),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
