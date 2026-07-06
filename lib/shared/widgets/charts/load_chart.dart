import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:kynos/core/theme/app_theme.dart';
import 'package:kynos/core/theme/motion.dart';
import 'package:kynos/domain/entities/health_summary.dart';

double? _toKm(double? meters) => meters == null ? null : meters / 1000;

/// Bar chart of recent running distance and active calories.
class LoadChart extends StatelessWidget {
  const LoadChart({super.key, required this.points});

  final List<HealthSummary> points;

  @override
  Widget build(BuildContext context) {
    final recent = points.length > 10
        ? points.sublist(points.length - 10)
        : points;

    final bars = <BarChartGroupData>[];
    for (var i = 0; i < recent.length; i++) {
      final km =
          _toKm(
            recent[i].runningWorkoutDistanceMeters ?? recent[i].distanceMeters,
          ) ??
          0;
      final active = (recent[i].activeCalories ?? 0) / 150;
      bars.add(
        BarChartGroupData(
          x: i,
          barsSpace: 4,
          barRods: [
            BarChartRodData(
              toY: km,
              color: AppTheme.stand,
              width: 7,
              borderRadius: BorderRadius.circular(3),
            ),
            BarChartRodData(
              toY: active,
              color: AppTheme.energy.withValues(alpha: 0.8),
              width: 7,
              borderRadius: BorderRadius.circular(3),
            ),
          ],
        ),
      );
    }

    return BarChart(
      BarChartData(
        gridData: const FlGridData(show: true, drawVerticalLine: false),
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
              getTitlesWidget: (value, meta) {
                final i = value.toInt();
                if (i < 0 || i >= recent.length) return const SizedBox.shrink();
                if (i.isOdd) return const SizedBox.shrink();
                final date = recent[i].date;
                return Text(
                  '${date.month}/${date.day}',
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppTheme.tertiaryLabel,
                  ),
                );
              },
            ),
          ),
        ),
        barGroups: bars,
      ),
      duration: Motion.medium,
      curve: Motion.curve,
    );
  }
}
