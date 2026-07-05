import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:kynos/core/theme/theme.dart';
import 'package:kynos/domain/entities/health_summary.dart';

/// Compact 7-day HRV sparkline for the readiness card.
class HrvSparkline extends StatelessWidget {
  const HrvSparkline({super.key, required this.history});

  final List<HealthSummary> history;

  @override
  Widget build(BuildContext context) {
    final kynos = context.kynosTheme;
    final cutoff = DateTime.now().subtract(const Duration(days: 7));
    final points = history.where((s) => s.date.isAfter(cutoff)).toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    final spots = <FlSpot>[];
    for (var i = 0; i < points.length; i++) {
      final hrv = points[i].hrvMs;
      if (hrv != null) spots.add(FlSpot(i.toDouble(), hrv));
    }

    if (spots.length < 2) {
      return Text(
        'Not enough HRV history for trend',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: kynos.tertiaryLabel,
            ),
      );
    }

    final minY = spots.map((e) => e.y).reduce(math.min) * 0.92;
    final maxY = spots.map((e) => e.y).reduce(math.max) * 1.08;

    return SizedBox(
      height: 48,
      child: LineChart(
        LineChartData(
          minY: minY,
          maxY: maxY,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: const FlTitlesData(show: false),
          lineTouchData: const LineTouchData(enabled: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: kynos.exercise,
              barWidth: 2,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: kynos.exercise.withValues(alpha: 0.12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
