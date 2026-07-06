import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:kynos/core/theme/app_theme.dart';
import 'package:kynos/domain/entities/health_summary.dart';
import 'package:kynos/shared/widgets/charts/chart_placeholder.dart';

/// Line chart of HRV recovery over recent health summaries.
class HrvChart extends StatelessWidget {
  const HrvChart({super.key, required this.points});

  final List<HealthSummary> points;

  @override
  Widget build(BuildContext context) {
    final hrvPoints = <FlSpot>[];
    for (var i = 0; i < points.length; i++) {
      final hrv = points[i].hrvMs;
      if (hrv != null) hrvPoints.add(FlSpot(i.toDouble(), hrv));
    }
    if (hrvPoints.isEmpty) {
      return const ChartPlaceholder(label: 'No HRV data yet');
    }
    final minY = hrvPoints.map((e) => e.y).reduce(math.min) * 0.9;
    final maxY = hrvPoints.map((e) => e.y).reduce(math.max) * 1.1;

    return LineChart(
      LineChartData(
        minY: minY,
        maxY: maxY,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: (maxY - minY) / 4,
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 22,
              getTitlesWidget: (value, meta) {
                if (value % 5 != 0) return const SizedBox.shrink();
                final i = value.toInt();
                if (i < 0 || i >= points.length) return const SizedBox.shrink();
                return Text(
                  '${points[i].date.month}/${points[i].date.day}',
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
            spots: hrvPoints,
            isCurved: true,
            color: AppTheme.exercise,
            barWidth: 3,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: AppTheme.exercise.withValues(alpha: 0.15),
            ),
          ),
        ],
      ),
    );
  }
}
