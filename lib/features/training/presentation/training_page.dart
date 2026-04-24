import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kynos/app/router.dart';
import 'package:kynos/core/theme/app_theme.dart';
import 'package:kynos/core/theme/spacing.dart' as tokens;
import 'package:kynos/domain/entities/health_summary.dart';
import 'package:kynos/domain/entities/insights/insight_confidence.dart';
import 'package:kynos/domain/entities/insights/training_insights.dart';
import 'package:kynos/domain/entities/workout_session.dart';
import 'package:kynos/shared/providers/health_provider.dart';
import 'package:kynos/shared/providers/nexus_lab_provider.dart';
import 'package:kynos/features/training/providers/training_insights_provider.dart';
import 'package:kynos/shared/utils/insight_text_formatter.dart';
import 'package:kynos/shared/widgets/kynos_card.dart';
import 'package:kynos/shared/widgets/metric_tile.dart';
import 'package:kynos/shared/widgets/run_card.dart';

/// Training tab — weekly stats, trends, runs, and gait model.
class TrainingPage extends ConsumerWidget {
  const TrainingPage({super.key});

  String _dateLabel() {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final now = DateTime.now();
    return '${days[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(healthHistoryProvider(days: 30));
    final recentRuns = ref.watch(recentRunsProvider(days: 365, limit: 60));
    final AsyncValue<NexusLabState>? labState = kIsWeb
        ? null
        : ref.watch(nexusLabNotifierProvider);
    final insightsState = ref.watch(trainingInsightsStateProvider);

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      slivers: [
        SliverAppBar(
          backgroundColor: AppTheme.background,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          pinned: true,
          toolbarHeight: 56,
          titleSpacing: 20,
          title: Text(
            _dateLabel(),
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppTheme.tertiaryLabel,
              letterSpacing: 0.2,
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            tokens.Spacing.md,
            0,
            tokens.Spacing.md,
            168,
          ),
          sliver: SliverList.list(
            children: [
              const _TrainingBanner(),
              const Gap(tokens.Spacing.lg),
              const _SectionHeader(title: 'This Week'),
              const Gap(tokens.Spacing.sm),
              _WeeklyStatsGrid(history: history.value ?? const []),
              const Gap(tokens.Spacing.lg),
              _TrainingInsightsCards(insightsState: insightsState),
              const Gap(tokens.Spacing.lg),
              const _SectionHeader(title: '30-Day Trends'),
              const Gap(tokens.Spacing.sm),
              _TrendCards(history: history.value ?? const []),
              const Gap(tokens.Spacing.lg),
              Row(
                children: [
                  const Expanded(child: _SectionHeader(title: 'Recent Runs')),
                  TextButton(
                    onPressed: () => context.push(Routes.runHistory),
                    child: const Text('View all'),
                  ),
                ],
              ),
              const Gap(tokens.Spacing.sm),
              _PastRunsList(runs: recentRuns.value ?? const []),
              const Gap(tokens.Spacing.lg),
              const _SectionHeader(title: 'Gait Model'),
              const Gap(tokens.Spacing.sm),
              _GaitModelCard(
                labState: labState,
                onCalibrate: kIsWeb
                    ? null
                    : () => ref
                          .read(nexusLabNotifierProvider.notifier)
                          .calibrate(),
              ),
              const Gap(tokens.Spacing.lg),
              const _PrivacyNotice(),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Training banner ───────────────────────────────────────────────────────────

class _TrainingBanner extends StatelessWidget {
  const _TrainingBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 130,
      decoration: BoxDecoration(
        color: AppTheme.exercise,
        borderRadius: BorderRadius.circular(20),
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.07),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Your progress',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.70),
                    letterSpacing: 0.2,
                  ),
                ),
                const Gap(4),
                Text(
                  'TRAINING',
                  style: GoogleFonts.inter(
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -1,
                    height: 1,
                  ),
                ),
                const Gap(6),
                Text(
                  'Trends, runs & gait model',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withValues(alpha: 0.60),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Weekly stats grid (2×2, uses MetricTile) ─────────────────────────────────

class _WeeklyStatsGrid extends StatelessWidget {
  const _WeeklyStatsGrid({required this.history});

  final List<HealthSummary> history;

  @override
  Widget build(BuildContext context) {
    final cutoff = DateTime.now().subtract(const Duration(days: 7));
    final week = history.where((s) => s.date.isAfter(cutoff)).toList();

    final totalKm = week
        .map(
          (s) =>
              (s.runningWorkoutDistanceMeters ?? s.distanceMeters ?? 0) / 1000,
        )
        .fold(0.0, (a, b) => a + b);

    final runCount = week
        .map((s) => s.runningWorkoutCount ?? 0)
        .fold(0, (a, b) => a + b);

    final hrvValues = week
        .where((s) => s.hrvMs != null)
        .map((s) => s.hrvMs!)
        .toList();
    final avgHrv = hrvValues.isEmpty
        ? null
        : hrvValues.fold(0.0, (a, b) => a + b) / hrvValues.length;

    final activeKcal = week
        .map((s) => s.activeCalories ?? 0)
        .fold(0.0, (a, b) => a + b);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: MetricTile(
                label: 'Distance',
                value: totalKm > 0 ? totalKm.toStringAsFixed(1) : '—',
                unit: 'km',
                accentColor: AppTheme.stand,
              ),
            ),
            const Gap(tokens.Spacing.sm),
            Expanded(
              child: MetricTile(
                label: 'Runs',
                value: runCount > 0 ? '$runCount' : '—',
                unit: null,
                accentColor: AppTheme.exercise,
              ),
            ),
          ],
        ),
        const Gap(tokens.Spacing.sm),
        Row(
          children: [
            Expanded(
              child: MetricTile(
                label: 'Avg recovery',
                value: avgHrv == null ? '—' : '${avgHrv.round()}',
                unit: 'ms',
                accentColor: AppTheme.purple,
              ),
            ),
            const Gap(tokens.Spacing.sm),
            Expanded(
              child: MetricTile(
                label: 'Active kcal',
                value: activeKcal > 0 ? '${activeKcal.round()}' : '—',
                unit: 'kcal',
                accentColor: AppTheme.energy,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Trend charts ──────────────────────────────────────────────────────────────

class _TrendCards extends StatelessWidget {
  const _TrendCards({required this.history});

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
                      ? const _ChartPlaceholder(label: 'No HRV data yet')
                      : _HrvChart(points: points),
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
                      ? const _ChartPlaceholder(label: 'No run history yet')
                      : _LoadChart(points: points),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TrainingInsightsCards extends StatelessWidget {
  const _TrainingInsightsCards({required this.insightsState});

  final AsyncValue<TrainingInsightsState> insightsState;

  @override
  Widget build(BuildContext context) {
    return insightsState.when(
      loading: () => const KynosCard(
        child: _InsightLoadingLine(label: 'Building training insights...'),
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (state) {
        final insights = state.insights;
        if (insights == null) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionHeader(title: 'Session Intent'),
            const Gap(tokens.Spacing.sm),
            _TrainingInsightTextCard(
              title: 'Session Intent',
              icon: Icons.track_changes_rounded,
              text: insights.sessionIntent,
              confidence: insights.confidence.label,
              usedModel: state.usedModel,
            ),
            const Gap(tokens.Spacing.md),
            const _SectionHeader(title: 'Adjustment Hints'),
            const Gap(tokens.Spacing.sm),
            _TrainingInsightListCard(
              title: 'Adjustments',
              icon: Icons.tune_rounded,
              lines: insights.adjustmentHints,
            ),
            const Gap(tokens.Spacing.md),
            const _SectionHeader(title: 'Post-Session Debrief'),
            const Gap(tokens.Spacing.sm),
            _TrainingInsightListCard(
              title: 'Debrief',
              icon: Icons.summarize_rounded,
              lines: insights.postSessionDebrief,
              evidence: insights.evidence,
            ),
          ],
        );
      },
    );
  }
}

class _InsightLoadingLine extends StatelessWidget {
  const _InsightLoadingLine({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(
          width: 12,
          height: 12,
          child: CircularProgressIndicator(
            strokeWidth: 1.5,
            color: AppTheme.tertiaryLabel,
          ),
        ),
        const Gap(tokens.Spacing.sm),
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 12, color: AppTheme.tertiaryLabel),
        ),
      ],
    );
  }
}

class _TrainingInsightTextCard extends StatefulWidget {
  const _TrainingInsightTextCard({
    required this.title,
    required this.icon,
    required this.text,
    required this.confidence,
    required this.usedModel,
  });

  final String title;
  final IconData icon;
  final String text;
  final String confidence;
  final bool usedModel;

  @override
  State<_TrainingInsightTextCard> createState() =>
      _TrainingInsightTextCardState();
}

class _TrainingInsightTextCardState extends State<_TrainingInsightTextCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final modeLabel = widget.usedModel ? 'Gemma' : 'Rules';
    return KynosCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(widget.icon, size: 14, color: AppTheme.secondaryLabel),
              const Gap(tokens.Spacing.sm),
              Expanded(
                child: Text(
                  widget.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              TextButton(
                onPressed: () => setState(() => _expanded = !_expanded),
                style: TextButton.styleFrom(
                  minimumSize: Size.zero,
                  padding: EdgeInsets.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(_expanded ? 'Hide' : 'Details'),
              ),
            ],
          ),
          const Gap(tokens.Spacing.sm),
          Wrap(
            spacing: tokens.Spacing.xs,
            runSpacing: tokens.Spacing.xs,
            children: [
              _TrainingChip(
                label: InsightTextFormatter.compactChipLabel(widget.text),
              ),
              _TrainingChip(label: 'Confidence ${widget.confidence}'),
              _TrainingChip(label: modeLabel),
            ],
          ),
          if (_expanded) ...[
            const Gap(tokens.Spacing.sm),
            Text(widget.text, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }
}

class _TrainingInsightListCard extends StatefulWidget {
  const _TrainingInsightListCard({
    required this.title,
    required this.icon,
    required this.lines,
    this.evidence = const [],
  });

  final String title;
  final IconData icon;
  final List<String> lines;
  final List<String> evidence;

  @override
  State<_TrainingInsightListCard> createState() =>
      _TrainingInsightListCardState();
}

class _TrainingInsightListCardState extends State<_TrainingInsightListCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return KynosCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(widget.icon, size: 14, color: AppTheme.secondaryLabel),
              const Gap(tokens.Spacing.sm),
              Expanded(
                child: Text(
                  widget.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              TextButton(
                onPressed: () => setState(() => _expanded = !_expanded),
                style: TextButton.styleFrom(
                  minimumSize: Size.zero,
                  padding: EdgeInsets.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(_expanded ? 'Hide' : 'Details'),
              ),
            ],
          ),
          const Gap(tokens.Spacing.sm),
          Wrap(
            spacing: tokens.Spacing.xs,
            runSpacing: tokens.Spacing.xs,
            children: [
              for (final line in widget.lines.take(2))
                _TrainingChip(
                  label: InsightTextFormatter.compactChipLabel(line),
                ),
              if (widget.evidence.isNotEmpty)
                _TrainingChip(label: '${widget.evidence.length} signals'),
            ],
          ),
          if (_expanded) ...[
            const Gap(tokens.Spacing.sm),
            for (final line in widget.lines.take(3)) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '• ',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppTheme.secondaryLabel,
                      height: 1.4,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      line,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
              const Gap(tokens.Spacing.xs),
            ],
            if (widget.evidence.isNotEmpty) ...[
              const Gap(tokens.Spacing.xs),
              Text(
                widget.evidence.join(' • '),
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppTheme.tertiaryLabel,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _TrainingChip extends StatelessWidget {
  const _TrainingChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: tokens.Spacing.sm,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(tokens.Radius.md),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 12,
          color: AppTheme.secondaryLabel,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _HrvChart extends StatelessWidget {
  const _HrvChart({required this.points});

  final List<HealthSummary> points;

  @override
  Widget build(BuildContext context) {
    final hrvPoints = <FlSpot>[];
    for (var i = 0; i < points.length; i++) {
      final hrv = points[i].hrvMs;
      if (hrv != null) hrvPoints.add(FlSpot(i.toDouble(), hrv));
    }
    if (hrvPoints.isEmpty) {
      return const _ChartPlaceholder(label: 'No HRV data yet');
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

class _LoadChart extends StatelessWidget {
  const _LoadChart({required this.points});

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
    );
  }
}

class _ChartPlaceholder extends StatelessWidget {
  const _ChartPlaceholder({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
    );
  }
}

// ── Past runs ─────────────────────────────────────────────────────────────────

class _PastRunsList extends StatelessWidget {
  const _PastRunsList({required this.runs});

  final List<WorkoutSession> runs;

  @override
  Widget build(BuildContext context) {
    if (runs.isEmpty) {
      return const KynosCard(
        child: _ChartPlaceholder(label: 'No completed runs found in HealthKit'),
      );
    }
    return Column(
      children: runs
          .take(8)
          .map(
            (run) => Padding(
              padding: const EdgeInsets.only(bottom: tokens.Spacing.sm),
              child: RunCard(run: run),
            ),
          )
          .toList(),
    );
  }
}

// ── Gait model card ───────────────────────────────────────────────────────────

class _GaitModelCard extends StatelessWidget {
  const _GaitModelCard({required this.labState, required this.onCalibrate});

  final AsyncValue<NexusLabState>? labState;
  final VoidCallback? onCalibrate;

  @override
  Widget build(BuildContext context) {
    return KynosCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: AppTheme.purple,
                  shape: BoxShape.circle,
                ),
              ),
              const Gap(tokens.Spacing.sm),
              Expanded(
                child: Text(
                  'Gait Model',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const Icon(
                Icons.lock_rounded,
                size: 12,
                color: AppTheme.tertiaryLabel,
              ),
              const Gap(tokens.Spacing.xs),
              Text(
                'On-device',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: AppTheme.tertiaryLabel,
                ),
              ),
            ],
          ),
          const Gap(tokens.Spacing.xs),
          Text(
            'Biomechanics regression trained on your run history. '
            'Predicts stride length from cadence and power.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const Gap(tokens.Spacing.md),
          if (labState == null)
            Text(
              'Gait model calibration is available on iOS devices only.',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppTheme.secondaryLabel,
              ),
            )
          else
            labState!.when(
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text(
                'Calibration unavailable: $e',
                style: GoogleFonts.inter(fontSize: 12, color: AppTheme.move),
              ),
              data: (state) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: MetricTile(
                          label: 'β0 Intercept',
                          value: _fmt(state.coefficients.b0),
                          accentColor: AppTheme.stand,
                        ),
                      ),
                      const Gap(tokens.Spacing.sm),
                      Expanded(
                        child: MetricTile(
                          label: 'β1 Cadence',
                          value: _fmt(state.coefficients.b1),
                          accentColor: AppTheme.exercise,
                        ),
                      ),
                      const Gap(tokens.Spacing.sm),
                      Expanded(
                        child: MetricTile(
                          label: 'β2 Power',
                          value: _fmt(state.coefficients.b2),
                          accentColor: AppTheme.energy,
                        ),
                      ),
                    ],
                  ),
                  if (state.calibratedAt != null) ...[
                    const Gap(tokens.Spacing.xs),
                    Text(
                      'Last calibrated ${_calibratedLabel(state.calibratedAt!)}',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppTheme.tertiaryLabel,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          const Gap(tokens.Spacing.md),
          FilledButton.icon(
            onPressed: onCalibrate,
            icon: const Icon(Icons.science_rounded, size: 18),
            label: Text(
              labState == null ? 'Available On iOS' : 'Run Calibration',
            ),
          ),
        ],
      ),
    );
  }

  String _fmt(double? v) => v == null ? '—' : v.toStringAsFixed(4);

  String _calibratedLabel(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

// ── Section header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppTheme.secondaryLabel,
        letterSpacing: 0.5,
      ),
    );
  }
}

// ── Privacy notice ────────────────────────────────────────────────────────────

class _PrivacyNotice extends StatelessWidget {
  const _PrivacyNotice();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.lock_rounded, size: 14, color: AppTheme.tertiaryLabel),
        const Gap(tokens.Spacing.sm),
        Text(
          'All data stays on your device',
          style: GoogleFonts.inter(fontSize: 11, color: AppTheme.tertiaryLabel),
        ),
      ],
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

double? _toKm(double? meters) => meters == null ? null : meters / 1000;
