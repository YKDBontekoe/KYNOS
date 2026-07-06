import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:kynos/core/theme/spacing.dart' as tokens;
import 'package:kynos/core/theme/theme.dart';
import 'package:kynos/domain/utils/pace_format.dart';
import 'package:kynos/domain/utils/run_route_analytics.dart';
import 'package:kynos/shared/widgets/charts/chart_placeholder.dart';
import 'package:kynos/shared/widgets/kynos_card.dart';

/// Pace-over-distance line chart for a single run.
class RunPaceChart extends StatelessWidget {
  const RunPaceChart({
    super.key,
    required this.analytics,
  });

  final RunRouteAnalytics analytics;

  @override
  Widget build(BuildContext context) {
    final kynos = context.kynosTheme;
    final profile = analytics.paceProfile;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: tokens.Spacing.md),
      child: KynosCard(
        child: SizedBox(
          height: 180,
          child: profile.length < 3
              ? const ChartPlaceholder(
                  label: 'Not enough GPS timestamps for pace profile',
                )
              : _PaceLineChart(profile: profile, kynos: kynos),
        ),
      ),
    );
  }
}

class _PaceLineChart extends StatelessWidget {
  const _PaceLineChart({
    required this.profile,
    required this.kynos,
  });

  final List<PaceProfilePoint> profile;
  final KynosThemeExtension kynos;

  @override
  Widget build(BuildContext context) {
    final spots = <FlSpot>[
      for (final point in profile)
        FlSpot(point.distanceKm, point.paceSecondsPerKm),
    ];

    final minPace = spots.map((s) => s.y).reduce(math.min);
    final maxPace = spots.map((s) => s.y).reduce(math.max);
    final pacePadding = (maxPace - minPace) * 0.15;
    final chartMinY = math.max(0.0, minPace - pacePadding).toDouble();
    final chartMaxY = (maxPace + pacePadding).toDouble();

    return LineChart(
      LineChartData(
        minY: chartMinY,
        maxY: chartMaxY,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: (chartMaxY - chartMinY) / 4,
          getDrawingHorizontalLine: (value) => FlLine(
            color: kynos.separator.withValues(alpha: 0.4),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 44,
              interval: (chartMaxY - chartMinY) / 3,
              getTitlesWidget: (value, meta) {
                final inverted = chartMaxY + chartMinY - value;
                return Text(
                  formatPacePerKm(inverted).replaceAll(' /km', ''),
                  style: kynos.metricValueStyle.copyWith(fontSize: 10),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 22,
              getTitlesWidget: (value, meta) {
                if (value == 0) return const SizedBox.shrink();
                return Text(
                  '${value.toStringAsFixed(1)} km',
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppTheme.tertiaryLabel,
                  ),
                );
              },
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: [
              for (final spot in spots)
                FlSpot(spot.x, chartMaxY + chartMinY - spot.y),
            ],
            isCurved: true,
            color: kynos.exercise,
            barWidth: 3,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: kynos.exercise.withValues(alpha: 0.15),
            ),
          ),
        ],
      ),
      duration: Motion.medium,
      curve: Motion.curve,
    );
  }
}
