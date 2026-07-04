import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kynos/core/theme/app_theme.dart';
import 'package:kynos/core/theme/spacing.dart' as tokens;
import 'package:kynos/domain/entities/health_summary.dart';
import 'package:kynos/domain/entities/insights/insight_confidence.dart';
import 'package:kynos/features/dashboard/providers/health_provider.dart';
import 'package:kynos/features/dashboard/providers/today_insights_provider.dart';
import 'package:kynos/shared/utils/insight_text_formatter.dart';
import 'package:kynos/shared/widgets/kynos_card.dart';
import 'package:kynos/shared/widgets/metric_tile.dart';

/// Today tab — readiness, AI insight, and today's health metrics.
class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 5) return 'Good night';
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    if (h < 21) return 'Good evening';
    return 'Good night';
  }

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
    final summary = ref.watch(healthSummaryProvider);
    final todayInsightsState = ref.watch(todayInsightsStateProvider);

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
              _HeroBanner(greeting: _greeting()),
              const Gap(tokens.Spacing.lg),
              _ReadinessCard(
                summary: summary.value,
                todayInsightsState: todayInsightsState,
              ),
              const Gap(tokens.Spacing.md),
              _TodayInsightCards(todayInsightsState: todayInsightsState),
              const Gap(tokens.Spacing.lg),
              const _SectionHeader(title: "Today's Metrics"),
              const Gap(tokens.Spacing.sm),
              _HealthMetricsGrid(summary: summary.value),
              const Gap(tokens.Spacing.lg),
              if (summary.value == null && !summary.isLoading)
                const _ConnectCard(),
              if (summary.value == null && !summary.isLoading)
                const Gap(tokens.Spacing.lg),
              const _PrivacyNotice(),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Hero banner ───────────────────────────────────────────────────────────────

class _HeroBanner extends StatelessWidget {
  const _HeroBanner({required this.greeting});

  final String greeting;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 130,
      decoration: BoxDecoration(
        color: AppTheme.stand,
        borderRadius: BorderRadius.circular(20),
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          Positioned(
            top: -40,
            left: -40,
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
                  greeting,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.70),
                    letterSpacing: 0.2,
                  ),
                ),
                const Gap(4),
                Text(
                  'KYNOS',
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
                  'Your AI running coach',
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

// ── Readiness card ────────────────────────────────────────────────────────────

class _ReadinessCard extends StatelessWidget {
  const _ReadinessCard({
    required this.summary,
    required this.todayInsightsState,
  });

  final HealthSummary? summary;
  final AsyncValue<TodayInsightsState> todayInsightsState;

  @override
  Widget build(BuildContext context) {
    final score = _readinessScore(summary);

    return KynosCard(
      padding: const EdgeInsets.all(tokens.Spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _ActivityRing(
                progress: score / 100,
                size: 82,
                strokeWidth: 8,
                colors: const [
                  AppTheme.move,
                  AppTheme.exercise,
                  AppTheme.stand,
                ],
              ),
              const Gap(tokens.Spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'READINESS',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    const Gap(tokens.Spacing.xs),
                    Text(
                      summary == null ? '—' : score.round().toString(),
                      style: GoogleFonts.inter(
                        fontSize: 38,
                        fontWeight: FontWeight.w800,
                        color: summary == null
                            ? AppTheme.secondaryLabel
                            : AppTheme.purple,
                        height: 1,
                        letterSpacing: -1,
                      ),
                    ),
                    const Gap(tokens.Spacing.xs),
                    Text(
                      summary == null
                          ? 'Connect HealthKit to calculate a real readiness score.'
                          : _readinessBrief(
                              score: score,
                              todayInsightsState: todayInsightsState,
                            ),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
          _ConfidenceBadgeRow(todayInsightsState: todayInsightsState),
        ],
      ),
    );
  }
}

class _ConfidenceBadgeRow extends StatelessWidget {
  const _ConfidenceBadgeRow({required this.todayInsightsState});

  final AsyncValue<TodayInsightsState> todayInsightsState;

  @override
  Widget build(BuildContext context) {
    return todayInsightsState.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (state) {
        final insights = state.insights;
        if (insights == null) return const SizedBox.shrink();
        return Column(
          children: [
            const Gap(tokens.Spacing.sm),
            const Divider(height: 1),
            const Gap(tokens.Spacing.sm),
            Row(
              children: [
                Icon(
                  Icons.verified_rounded,
                  size: 14,
                  color: AppTheme.purple.withValues(alpha: 0.75),
                ),
                const Gap(tokens.Spacing.sm),
                Text(
                  'Confidence: ${insights.confidence.label}${state.usedModel ? ' • Gemma refined' : ' • Rule-based'}',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppTheme.tertiaryLabel,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _TodayInsightCards extends StatelessWidget {
  const _TodayInsightCards({required this.todayInsightsState});

  final AsyncValue<TodayInsightsState> todayInsightsState;

  @override
  Widget build(BuildContext context) {
    return todayInsightsState.when(
      loading: () => const KynosCard(
        child: _LoadingLine(label: 'Generating today insights...'),
      ),
      error: (_, _) => const SizedBox.shrink(),
      data: (state) {
        final insights = state.insights;
        if (insights == null) {
          return const SizedBox.shrink();
        }

        return Column(
          children: [
            _InsightExpandableCard(
              title: 'Quick Changes',
              icon: Icons.compare_arrows_rounded,
              lines: insights.whatChanged,
            ),
            const Gap(tokens.Spacing.md),
            _InsightExpandableCard(
              title: 'Top Risks',
              icon: Icons.warning_amber_rounded,
              lines: insights.riskFlags,
            ),
            const Gap(tokens.Spacing.md),
            _ActionCompactCard(
              actionNow: insights.actionNow,
              actionTonight: insights.actionTonight,
              evidence: insights.evidence,
            ),
          ],
        );
      },
    );
  }
}

class _LoadingLine extends StatelessWidget {
  const _LoadingLine({required this.label});

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

class _InsightExpandableCard extends StatefulWidget {
  const _InsightExpandableCard({
    required this.title,
    required this.icon,
    required this.lines,
  });

  final String title;
  final IconData icon;
  final List<String> lines;

  @override
  State<_InsightExpandableCard> createState() => _InsightExpandableCardState();
}

class _InsightExpandableCardState extends State<_InsightExpandableCard> {
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
                _CompactChip(
                  label: InsightTextFormatter.compactChipLabel(line),
                ),
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
          ],
        ],
      ),
    );
  }
}

class _ActionCompactCard extends StatefulWidget {
  const _ActionCompactCard({
    required this.actionNow,
    required this.actionTonight,
    required this.evidence,
  });

  final String actionNow;
  final String actionTonight;
  final List<String> evidence;

  @override
  State<_ActionCompactCard> createState() => _ActionCompactCardState();
}

class _ActionCompactCardState extends State<_ActionCompactCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return KynosCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Quick Actions',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              TextButton(
                onPressed: () => setState(() => _expanded = !_expanded),
                style: TextButton.styleFrom(
                  minimumSize: Size.zero,
                  padding: EdgeInsets.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(_expanded ? 'Hide' : 'Open'),
              ),
            ],
          ),
          const Gap(tokens.Spacing.sm),
          Wrap(
            spacing: tokens.Spacing.xs,
            runSpacing: tokens.Spacing.xs,
            children: [
              const _CompactChip(label: 'Now'),
              const _CompactChip(label: 'Tonight'),
              if (widget.evidence.isNotEmpty)
                _CompactChip(label: '${widget.evidence.length} signals'),
            ],
          ),
          if (_expanded) ...[
            const Gap(tokens.Spacing.sm),
            _ActionRow(
              icon: Icons.play_arrow_rounded,
              label: 'Now',
              value: widget.actionNow,
            ),
            const Gap(tokens.Spacing.xs),
            _ActionRow(
              icon: Icons.nights_stay_rounded,
              label: 'Tonight',
              value: widget.actionTonight,
            ),
            if (widget.evidence.isNotEmpty) ...[
              const Gap(tokens.Spacing.sm),
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

class _CompactChip extends StatelessWidget {
  const _CompactChip({required this.label});

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

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: AppTheme.secondaryLabel),
        const Gap(tokens.Spacing.xs),
        Text(
          '$label:',
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppTheme.secondaryLabel,
          ),
        ),
        const Gap(tokens.Spacing.xs),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// ── Metrics grid ──────────────────────────────────────────────────────────────

class _HealthMetricsGrid extends StatelessWidget {
  const _HealthMetricsGrid({required this.summary});

  final HealthSummary? summary;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: MetricTile(
                label: 'Recovery',
                value: _round(summary?.hrvMs),
                unit: 'ms',
                accentColor: AppTheme.exercise,
              ),
            ),
            const Gap(tokens.Spacing.sm),
            Expanded(
              child: MetricTile(
                label: 'Resting pulse',
                value: _round(summary?.rhrBpm),
                unit: 'bpm',
                accentColor: AppTheme.move,
              ),
            ),
          ],
        ),
        const Gap(tokens.Spacing.sm),
        Row(
          children: [
            Expanded(
              child: MetricTile(
                label: 'Sleep',
                value: _fixed(summary?.sleepHours, 1),
                unit: 'h',
                accentColor: AppTheme.stand,
              ),
            ),
            const Gap(tokens.Spacing.sm),
            Expanded(
              child: MetricTile(
                label: 'SpO2',
                value: _fixed(summary?.bloodOxygenPercent, 1),
                unit: '%',
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
                label: 'Distance',
                value: _fixed(_toKm(summary?.distanceMeters), 2),
                unit: 'km',
                accentColor: AppTheme.stand,
              ),
            ),
            const Gap(tokens.Spacing.sm),
            Expanded(
              child: MetricTile(
                label: 'Steps',
                value: summary?.steps?.toString() ?? '—',
                unit: null,
                accentColor: AppTheme.energy,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Connect HealthKit card ────────────────────────────────────────────────────

class _ConnectCard extends ConsumerWidget {
  const _ConnectCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return KynosCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Connect HealthKit',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const Gap(tokens.Spacing.xs),
          Text(
            'Grant access to recovery and workout data to unlock your readiness score and AI coaching insights.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const Gap(tokens.Spacing.md),
          FilledButton(
            onPressed: () async {
              await ref
                  .read(healthPermissionsNotifierProvider.notifier)
                  .request();
            },
            child: const Text('Connect HealthKit'),
          ),
        ],
      ),
    );
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

// ── Activity ring ─────────────────────────────────────────────────────────────

class _ActivityRing extends StatelessWidget {
  const _ActivityRing({
    required this.progress,
    required this.size,
    required this.strokeWidth,
    required this.colors,
  });

  final double progress;
  final double size;
  final double strokeWidth;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(
          progress: progress,
          strokeWidth: strokeWidth,
          colors: colors,
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.colors,
  });

  final double progress;
  final double strokeWidth;
  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    for (var i = 0; i < colors.length; i++) {
      final spacing = strokeWidth * 0.28;
      final radius =
          (size.width / 2) - strokeWidth / 2 - (strokeWidth + spacing) * i;

      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..color = colors[i].withValues(alpha: 0.15),
      );

      if (progress > 0) {
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          -math.pi / 2,
          2 * math.pi * progress,
          false,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = strokeWidth
            ..color = colors[i]
            ..strokeCap = StrokeCap.round,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}

// ── Helpers ───────────────────────────────────────────────────────────────────

double _readinessScore(HealthSummary? summary) {
  if (summary == null) return 0;

  final hrvScore = ((summary.hrvMs ?? 20).clamp(20, 110) - 20) / 90;
  final rhrScore = 1 - (((summary.rhrBpm ?? 75).clamp(45, 90) - 45) / 45);
  final sleepScore = ((summary.sleepHours ?? 5).clamp(4, 9) - 4) / 5;
  final spo2Score =
      ((summary.bloodOxygenPercent ?? 95).clamp(90, 100) - 90) / 10;

  return ((hrvScore * 0.35 +
              rhrScore * 0.25 +
              sleepScore * 0.25 +
              spo2Score * 0.15) *
          100)
      .clamp(0, 100);
}

String _readinessBrief({
  required double score,
  required AsyncValue<TodayInsightsState> todayInsightsState,
}) {
  final todayInsights = todayInsightsState.value?.insights;
  if (todayInsights != null && todayInsights.readinessBrief.isNotEmpty) {
    return todayInsights.readinessBrief;
  }
  return _readinessSummary(score);
}

String _readinessSummary(double score) {
  if (score >= 80) {
    return 'Strong recovery. High quality session is supported today.';
  }
  if (score >= 65) {
    return 'Stable recovery. Tempo or aerobic run should feel good.';
  }
  if (score >= 45) return 'Moderate readiness. Keep intensity controlled.';
  return 'Low readiness. Prioritise recovery and easy movement.';
}

String _round(double? value) => value == null ? '—' : value.round().toString();

String _fixed(double? value, int digits) =>
    value == null ? '—' : value.toStringAsFixed(digits);

double? _toKm(double? meters) => meters == null ? null : meters / 1000;
