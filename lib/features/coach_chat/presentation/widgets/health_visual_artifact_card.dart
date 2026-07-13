import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:kynos/core/theme/theme.dart';
import 'package:kynos/domain/entities/health/health_visual_artifact.dart';
import 'package:kynos/shared/widgets/kynos_card.dart';

class HealthVisualArtifactCard extends StatefulWidget {
  const HealthVisualArtifactCard({
    super.key,
    required this.artifact,
    required this.onExplore,
  });

  final HealthVisualArtifact artifact;
  final ValueChanged<String> onExplore;

  @override
  State<HealthVisualArtifactCard> createState() =>
      _HealthVisualArtifactCardState();
}

class _HealthVisualArtifactCardState extends State<HealthVisualArtifactCard> {
  bool _showTable = false;
  int _rangeDays = 30;
  String? _seriesId;

  HealthArtifactMeta get _meta => switch (widget.artifact) {
    HealthTrendArtifact(:final meta) => meta,
    HealthComparisonTableArtifact(:final meta) => meta,
    HealthCorrelationScatterArtifact(:final meta) => meta,
    HealthCalendarHeatmapArtifact(:final meta) => meta,
    HealthTimelineArtifact(:final meta) => meta,
    HealthInfluenceMapArtifact(:final meta) => meta,
    _ => throw StateError('Unsupported health artifact'),
  };

  @override
  Widget build(BuildContext context) {
    final artifact = widget.artifact;
    return Semantics(
      label: '${_meta.title}. ${_meta.explanation}',
      child: KynosCard(
        padding: const EdgeInsets.all(Spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    _meta.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Icon(
                  Icons.insights_rounded,
                  color: context.kynosTheme.purple,
                  size: 20,
                ),
              ],
            ),
            const Gap(Spacing.xs),
            Text(
              _meta.explanation,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const Gap(Spacing.md),
            if (artifact case HealthTrendArtifact()) _trend(artifact),
            if (artifact case HealthComparisonTableArtifact())
              _comparisonTable(artifact),
            if (artifact case HealthCorrelationScatterArtifact())
              _scatter(artifact),
            if (artifact case HealthCalendarHeatmapArtifact())
              _heatmap(artifact),
            if (artifact case HealthTimelineArtifact()) _timeline(artifact),
            if (artifact case HealthInfluenceMapArtifact())
              _influenceMap(artifact),
            if (_meta.limitations.isNotEmpty) ...[
              const Gap(Spacing.sm),
              Text(
                _meta.limitations.join(' '),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: context.kynosTheme.secondaryLabel,
                ),
              ),
            ],
            const Gap(Spacing.sm),
            Row(
              children: [
                Text(
                  '${_meta.confidence.name} confidence',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => widget.onExplore(
                    'Explain the finding in “${_meta.title}”, including uncertainty and missing data.',
                  ),
                  icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16),
                  label: const Text('Ask KYNOS'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _trend(HealthTrendArtifact artifact) {
    final availableSeries = artifact.series
        .where((item) => item.points.isNotEmpty)
        .toList();
    if (availableSeries.isEmpty) return const Text('No points available.');
    _seriesId ??= availableSeries.first.id;
    final series = availableSeries.firstWhere(
      (item) => item.id == _seriesId,
      orElse: () => availableSeries.first,
    );
    final cutoff = DateTime.now().subtract(Duration(days: _rangeDays));
    final points = series.points
        .where((item) => !item.date.isBefore(cutoff))
        .toList();
    final visible = points.isEmpty ? series.points : points;
    if (_showTable) {
      return Column(
        children: [
          _trendControls(availableSeries),
          ...visible.map(
            (point) => _ValueRow(
              label: _date(point.date),
              value: '${_number(point.value)} ${series.unit}',
              onTap: () => widget.onExplore(
                'Explain ${series.label} on ${_date(point.date)}.',
              ),
            ),
          ),
        ],
      );
    }
    final values = visible.map((item) => item.value).toList();
    final minimum = values.reduce(math.min);
    final maximum = values.reduce(math.max);
    final padding = math.max((maximum - minimum) * 0.15, 1);
    return Column(
      children: [
        _trendControls(availableSeries),
        SizedBox(
          height: 190,
          child: LineChart(
            LineChartData(
              minY: minimum - padding,
              maxY: maximum + padding,
              borderData: FlBorderData(show: false),
              gridData: const FlGridData(show: true, drawVerticalLine: false),
              titlesData: const FlTitlesData(
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              lineTouchData: LineTouchData(
                touchCallback: (event, response) {
                  final index = response?.lineBarSpots?.firstOrNull?.spotIndex;
                  if (index == null || index >= visible.length) return;
                  final point = visible[index];
                  if (event is FlTapUpEvent) {
                    widget.onExplore(
                      'Explain ${series.label} on ${_date(point.date)} when it was '
                      '${_number(point.value)} ${series.unit}.',
                    );
                  }
                },
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: [
                    for (var i = 0; i < visible.length; i++)
                      FlSpot(i.toDouble(), visible[i].value),
                  ],
                  isCurved: true,
                  color: context.kynosTheme.purple,
                  barWidth: 2.5,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: context.kynosTheme.purple.withValues(alpha: 0.12),
                  ),
                ),
              ],
              extraLinesData: series.baseline == null
                  ? const ExtraLinesData()
                  : ExtraLinesData(
                      horizontalLines: [
                        HorizontalLine(
                          y: series.baseline!,
                          color: context.kynosTheme.secondaryLabel,
                          dashArray: [4, 4],
                          strokeWidth: 1,
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _trendControls(List<HealthSeries> series) => Column(
    children: [
      if (series.length > 1)
        Wrap(
          spacing: Spacing.xs,
          children: series
              .map(
                (item) => ChoiceChip(
                  label: Text(item.label),
                  selected: item.id == _seriesId,
                  onSelected: (_) => setState(() => _seriesId = item.id),
                ),
              )
              .toList(),
        ),
      Row(
        children: [
          for (final days in const [7, 30, 90])
            TextButton(
              onPressed: () => setState(() => _rangeDays = days),
              child: Text('$days D'),
            ),
          const Spacer(),
          IconButton(
            tooltip: _showTable ? 'Show chart' : 'Show accessible table',
            onPressed: () => setState(() => _showTable = !_showTable),
            icon: Icon(_showTable ? Icons.show_chart : Icons.table_rows),
          ),
        ],
      ),
    ],
  );

  Widget _comparisonTable(HealthComparisonTableArtifact artifact) => Column(
    children: artifact.rows
        .map(
          (row) => _ValueRow(
            label: row.label,
            value: row.values.join(' · '),
            onTap: () => widget.onExplore(
              'Explain the “${row.label}” row in ${artifact.meta.title}.',
            ),
          ),
        )
        .toList(),
  );

  Widget _scatter(HealthCorrelationScatterArtifact artifact) {
    if (artifact.points.isEmpty) return const Text('No paired observations.');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 190,
          child: ScatterChart(
            ScatterChartData(
              scatterSpots: artifact.points
                  .map(
                    (point) => ScatterSpot(
                      point.x,
                      point.y,
                      dotPainter: FlDotCirclePainter(
                        radius: 4,
                        color: context.kynosTheme.purple,
                      ),
                    ),
                  )
                  .toList(),
              borderData: FlBorderData(show: false),
              gridData: const FlGridData(show: true),
              titlesData: const FlTitlesData(
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
            ),
          ),
        ),
        Text(
          'ρ ${artifact.correlation.toStringAsFixed(2)} · '
          '${artifact.points.length} paired observations · association only',
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ],
    );
  }

  Widget _heatmap(HealthCalendarHeatmapArtifact artifact) => Wrap(
    spacing: 4,
    runSpacing: 4,
    children: artifact.points.map((point) {
      final opacity = (point.value.abs() / 100).clamp(0.15, 1.0);
      return Tooltip(
        message: '${_date(point.date)} · ${_number(point.value)}',
        child: InkWell(
          onTap: () => widget.onExplore(
            'Explain ${artifact.metric.label} on ${_date(point.date)}.',
          ),
          child: Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: context.kynosTheme.purple.withValues(alpha: opacity),
              borderRadius: BorderRadius.circular(Radius.sm),
            ),
          ),
        ),
      );
    }).toList(),
  );

  Widget _timeline(HealthTimelineArtifact artifact) => Column(
    children: artifact.events
        .take(20)
        .map(
          (event) => _ValueRow(
            label: '${_date(event.date)} · ${event.title}',
            value: event.detail,
            onTap: () => widget.onExplore(
              'Explain the ${event.title.toLowerCase()} event on ${_date(event.date)}.',
            ),
          ),
        )
        .toList(),
  );

  Widget _influenceMap(HealthInfluenceMapArtifact artifact) => Column(
    children: artifact.edges
        .map(
          (edge) => ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('${edge.from} → ${edge.to}'),
            subtitle: Text('${edge.label} · association, not causation'),
            onTap: () => widget.onExplore(
              'Explain the possible relationship between ${edge.from} and ${edge.to}.',
            ),
          ),
        )
        .toList(),
  );

  String _date(DateTime date) => '${date.day}/${date.month}';

  String _number(double value) =>
      value.abs() >= 100 ? value.round().toString() : value.toStringAsFixed(1);
}

class _ValueRow extends StatelessWidget {
  const _ValueRow({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: Spacing.sm),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          const Gap(Spacing.sm),
          Text(value, style: context.kynosTheme.metricValueStyle),
        ],
      ),
    ),
  );
}
