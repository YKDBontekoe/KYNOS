import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kynos/core/theme/app_theme.dart';
import 'package:kynos/core/theme/spacing.dart' as tokens;
import 'package:kynos/domain/entities/health_summary.dart';
import 'package:kynos/features/dashboard/providers/health_provider.dart';
import 'package:kynos/shared/widgets/metric_tile.dart';

/// Today tab — health metrics, readiness ring, and connect card.
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
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final now = DateTime.now();
    return '${days[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final healthSummary = ref.watch(healthSummaryProvider);

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
          actions: [
            GestureDetector(
              onTap: () {},
              child: Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(
                  color: AppTheme.separator,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_rounded,
                  size: 18,
                  color: AppTheme.secondaryLabel,
                ),
              ),
            ),
            const Gap(20),
          ],
        ),

        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
          sliver: SliverList.list(
            children: [
              _HeroBanner(greeting: _greeting()),
              const Gap(tokens.Spacing.lg),

              const _ReadinessCard(),
              const Gap(tokens.Spacing.lg),

              const _SectionHeader(title: "Today's Metrics"),
              const Gap(tokens.Spacing.sm),
              healthSummary.when(
                data: (summary) => _HealthMetricsGrid(summary: summary),
                loading: () => const _HealthMetricsGrid(summary: null),
                error: (e, s) => Center(
                  child: Text(
                    'Error loading metrics: $e',
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ),
              const Gap(tokens.Spacing.lg),

              if (healthSummary.value == null && !healthSummary.isLoading) ...[
                const _SectionHeader(title: 'Get Started'),
                const Gap(tokens.Spacing.sm),
                const _ConnectCard(),
                const Gap(tokens.Spacing.lg),
              ],

              const _PrivacyNotice(),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Health metrics grid ─────────────────────────────────────────────────────

class _HealthMetricsGrid extends StatelessWidget {
  final HealthSummary? summary;

  const _HealthMetricsGrid({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: MetricTile(
                label: 'HRV',
                value: summary == null ? null : (summary!.hrvMs?.round().toString() ?? '—'),
                unit: 'ms',
                accentColor: AppTheme.exercise,
              ),
            ),
            const Gap(tokens.Spacing.sm),
            Expanded(
              child: MetricTile(
                label: 'Resting HR',
                value: summary == null ? null : (summary!.rhrBpm?.round().toString() ?? '—'),
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
                value: summary == null ? null : (summary!.sleepHours?.toStringAsFixed(1) ?? '—'),
                unit: 'h',
                accentColor: AppTheme.stand,
              ),
            ),
            const Gap(tokens.Spacing.sm),
            Expanded(
              child: MetricTile(
                label: 'Active kcal',
                value: summary == null ? null : (summary!.activeCalories?.round().toString() ?? '—'),
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

// ── Hero banner ────────────────────────────────────────────────────────────

class _HeroBanner extends StatelessWidget {
  final String greeting;
  const _HeroBanner({required this.greeting});

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
            child: Row(
              children: [
                Expanded(
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
                          letterSpacing: -1.0,
                          height: 1.0,
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
          ),
        ],
      ),
    );
  }
}

// ── Section header ─────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

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

// ── Readiness card ─────────────────────────────────────────────────────────

class _ReadinessCard extends ConsumerWidget {
  const _ReadinessCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final healthSummary = ref.watch(healthSummaryProvider);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _ActivityRing(
            progress: healthSummary.when(
              data: (summary) => summary != null ? 0.75 : 0.0,
              loading: () => 0.0,
              error: (e, s) => 0.0,
            ),
            size: 80,
            strokeWidth: 8,
            colors: const [AppTheme.move, AppTheme.exercise, AppTheme.stand],
          ),
          const Gap(20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'READINESS',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.secondaryLabel,
                    letterSpacing: 0.8,
                  ),
                ),
                const Gap(4),
                healthSummary.when(
                  data: (summary) => Text(
                    summary != null ? '87' : '—',
                    style: GoogleFonts.inter(
                      fontSize: 40,
                      fontWeight: FontWeight.w800,
                      color: summary != null ? AppTheme.purple : AppTheme.label,
                      height: 1,
                      letterSpacing: -1,
                    ),
                  ),
                  loading: () => const SizedBox(
                    height: 40,
                    child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  ),
                  error: (e, s) => Text(
                    'Error',
                    style: GoogleFonts.inter(fontSize: 24, color: Colors.red),
                  ),
                ),
                const Gap(6),
                Text(
                  healthSummary.when(
                    data: (summary) => summary != null
                        ? 'Great recovery. Optimal conditions for a high-intensity interval run today.'
                        : 'Connect HealthKit to unlock your daily readiness.',
                    loading: () => 'Calculating readiness...',
                    error: (e, s) => 'Could not calculate readiness.',
                  ),
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppTheme.secondaryLabel,
                    height: 1.4,
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

// ── Activity rings ─────────────────────────────────────────────────────────

class _ActivityRing extends StatelessWidget {
  final double progress;
  final double size;
  final double strokeWidth;
  final List<Color> colors;

  const _ActivityRing({
    required this.progress,
    required this.size,
    required this.strokeWidth,
    required this.colors,
  });

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
  final double progress;
  final double strokeWidth;
  final List<Color> colors;

  const _RingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.colors,
  });

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

// ── Connect card ───────────────────────────────────────────────────────────

class _ConnectCard extends ConsumerWidget {
  const _ConnectCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppTheme.exercise.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.health_and_safety_rounded,
                    color: AppTheme.exercise,
                    size: 24,
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Connect HealthKit',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.label,
                        ),
                      ),
                      Text(
                        'Required for AI coaching',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppTheme.secondaryLabel,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppTheme.tertiaryLabel,
                  size: 20,
                ),
              ],
            ),
          ),
          const Divider(height: 0, indent: 72),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Grant access to HRV, resting heart rate, sleep, and activity '
                  'data to unlock personalised AI coaching.',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppTheme.secondaryLabel,
                    height: 1.5,
                  ),
                ),
                const Gap(16),
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
          ),
        ],
      ),
    );
  }
}

// ── Privacy notice ──────────────────────────────────────────────────────────

class _PrivacyNotice extends StatelessWidget {
  const _PrivacyNotice();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.lock_rounded,
          size: 14,
          color: AppTheme.tertiaryLabel,
        ),
        const Gap(tokens.Spacing.sm),
        Text(
          'All data stays on your device',
          style: GoogleFonts.inter(
            fontSize: 11,
            color: AppTheme.tertiaryLabel,
          ),
        ),
      ],
    );
  }
}
