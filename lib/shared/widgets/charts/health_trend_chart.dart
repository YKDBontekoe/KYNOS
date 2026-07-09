import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:kynos/core/theme/theme.dart';
import 'package:kynos/domain/entities/health_summary.dart';
import 'package:kynos/domain/utils/running_distance.dart';

enum HealthChartMetric {
  recovery,
  restingPulse,
  sleep,
  bloodOxygen,
  distance,
  activeEnergy,
  exercise,
}

enum HealthChartRange {
  week(7, '7D'),
  month(30, '30D'),
  quarter(90, '90D'),
  year(365, '1Y');

  const HealthChartRange(this.days, this.label);
  final int days;
  final String label;
}

extension HealthChartMetricLabel on HealthChartMetric {
  String get label => switch (this) {
    HealthChartMetric.recovery => 'Recovery',
    HealthChartMetric.restingPulse => 'Resting pulse',
    HealthChartMetric.sleep => 'Sleep',
    HealthChartMetric.bloodOxygen => 'Blood oxygen',
    HealthChartMetric.distance => 'Run distance',
    HealthChartMetric.activeEnergy => 'Active energy',
    HealthChartMetric.exercise => 'Exercise time',
  };

  String get unit => switch (this) {
    HealthChartMetric.recovery => 'ms',
    HealthChartMetric.restingPulse => 'bpm',
    HealthChartMetric.sleep => 'h',
    HealthChartMetric.bloodOxygen => '%',
    HealthChartMetric.distance => 'km',
    HealthChartMetric.activeEnergy => 'kcal',
    HealthChartMetric.exercise => 'min',
  };
}

class HealthTrendPoint {
  const HealthTrendPoint({required this.date, required this.value});
  final DateTime date;
  final double value;
}

List<HealthTrendPoint> buildHealthTrendPoints(
  List<HealthSummary> history, {
  required HealthChartMetric metric,
  required HealthChartRange range,
}) {
  final sorted = List<HealthSummary>.from(history)
    ..sort((a, b) => a.date.compareTo(b.date));
  final cutoff = DateTime.now().subtract(Duration(days: range.days));
  final recent = sorted.where((item) => item.date.isAfter(cutoff)).toList();
  if (range == HealthChartRange.year) {
    final buckets = <DateTime, List<double>>{};
    for (final item in recent) {
      final weekStart = item.date.subtract(
        Duration(days: item.date.weekday - 1),
      );
      final key = DateTime(weekStart.year, weekStart.month, weekStart.day);
      final value = _metricValue(item, metric);
      if (value != null) buckets.putIfAbsent(key, () => []).add(value);
    }
    return buckets.entries
        .map(
          (entry) => HealthTrendPoint(
            date: entry.key,
            value: entry.value.reduce((a, b) => a + b) / entry.value.length,
          ),
        )
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }
  return recent
      .map((item) {
        final value = _metricValue(item, metric);
        return value == null
            ? null
            : HealthTrendPoint(date: item.date, value: value);
      })
      .whereType<HealthTrendPoint>()
      .toList();
}

double? _metricValue(HealthSummary item, HealthChartMetric metric) =>
    switch (metric) {
      HealthChartMetric.recovery => item.hrvMs,
      HealthChartMetric.restingPulse => item.rhrBpm,
      HealthChartMetric.sleep => item.sleepHours,
      HealthChartMetric.bloodOxygen => item.bloodOxygenPercent,
      HealthChartMetric.distance => dailyRunningDistanceKm(item),
      HealthChartMetric.activeEnergy => item.activeCalories,
      HealthChartMetric.exercise => item.exerciseMinutes,
    };

class HealthTrendChart extends StatefulWidget {
  const HealthTrendChart({
    super.key,
    required this.history,
    required this.metric,
    required this.range,
    this.comparisonHistory = const [],
    this.onSelectionChanged,
  });

  final List<HealthSummary> history;
  final List<HealthSummary> comparisonHistory;
  final HealthChartMetric metric;
  final HealthChartRange range;
  final ValueChanged<HealthTrendPoint?>? onSelectionChanged;

  @override
  State<HealthTrendChart> createState() => _HealthTrendChartState();
}

class _HealthTrendChartState extends State<HealthTrendChart> {
  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    final points = buildHealthTrendPoints(
      widget.history,
      metric: widget.metric,
      range: widget.range,
    );
    if (points.isEmpty) {
      return Center(
        child: Text(
          'No ${widget.metric.label.toLowerCase()} data yet',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      );
    }
    final values = points.map((point) => point.value).toList();
    final minValue = values.reduce(math.min);
    final maxValue = values.reduce(math.max);
    final padding = math.max((maxValue - minValue) * 0.18, 1);
    final selected = _selectedIndex != null && _selectedIndex! < points.length
        ? points[_selectedIndex!]
        : points.last;
    final color = context.kynosTheme.exercise;
    final comparisonValues = widget.comparisonHistory
        .map((item) => _metricValue(item, widget.metric))
        .whereType<double>()
        .toList();
    final comparison = comparisonValues.isEmpty
        ? null
        : comparisonValues.reduce((a, b) => a + b) / comparisonValues.length;
    final comparisonLabel = comparison == null
        ? null
        : ' ${comparison >= selected.value ? '↓' : '↑'} '
              '${_formatValue((selected.value - comparison).abs())} ${widget.metric.unit} vs earlier';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              widget.metric.label,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Spacer(),
            Text(
              '${_formatValue(selected.value)} ${widget.metric.unit}',
              style: context.kynosTheme.metricValueStyle.copyWith(fontSize: 16),
            ),
          ],
        ),
        const SizedBox(height: Spacing.xs),
        Text(
          '${_formatDate(selected.date)} · drag to inspect${comparisonLabel ?? ''}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: Spacing.md),
        Expanded(
          child: LineChart(
            LineChartData(
              minY: math.max(0, minValue - padding),
              maxY: maxValue + padding,
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: math.max((maxValue - minValue) / 3, 1),
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
                      final index = value.round();
                      if (index < 0 ||
                          index >= points.length ||
                          index % math.max(points.length ~/ 4, 1) != 0) {
                        return const SizedBox.shrink();
                      }
                      return Text(
                        _formatDate(points[index].date),
                        style: Theme.of(context).textTheme.labelSmall,
                      );
                    },
                  ),
                ),
              ),
              lineTouchData: LineTouchData(
                handleBuiltInTouches: true,
                touchCallback: (event, response) {
                  final index = response?.lineBarSpots?.firstOrNull?.spotIndex;
                  if (index == null || index < 0 || index >= points.length) {
                    return;
                  }
                  setState(() => _selectedIndex = index);
                  widget.onSelectionChanged?.call(points[index]);
                },
                touchTooltipData: LineTouchTooltipData(
                  getTooltipItems: (spots) => spots
                      .map(
                        (spot) => LineTooltipItem(
                          '${_formatValue(spot.y)} ${widget.metric.unit}',
                          TextStyle(color: color, fontWeight: FontWeight.w600),
                        ),
                      )
                      .toList(),
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: [
                    for (var i = 0; i < points.length; i++)
                      FlSpot(i.toDouble(), points[i].value),
                  ],
                  isCurved: true,
                  color: color,
                  barWidth: 2.5,
                  dotData: FlDotData(show: _selectedIndex != null),
                  belowBarData: BarAreaData(
                    show: true,
                    color: color.withValues(alpha: 0.12),
                  ),
                ),
              ],
            ),
            duration: Motion.medium,
            curve: Motion.curve,
          ),
        ),
      ],
    );
  }
}

String _formatValue(double value) =>
    value >= 100 ? value.round().toString() : value.toStringAsFixed(1);

String _formatDate(DateTime date) => '${date.month}/${date.day}';
