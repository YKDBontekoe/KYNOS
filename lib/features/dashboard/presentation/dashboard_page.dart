import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kynos/core/theme/app_theme.dart';
import 'package:kynos/core/theme/spacing.dart' as tokens;
import 'package:kynos/domain/entities/health_summary.dart';
import 'package:kynos/features/dashboard/providers/health_provider.dart';
import 'package:kynos/shared/widgets/metric_tile.dart';
import 'package:kynos/core/utils/readiness_calculator.dart';
import 'package:kynos/features/dashboard/presentation/widgets/coach_insight_card.dart';
import 'package:kynos/features/dashboard/presentation/widgets/recovery_trend_chart.dart';
import 'package:kynos/features/dashboard/presentation/widgets/readiness_card.dart';

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
    final healthSummaryAsync = ref.watch(healthSummaryProvider);

    // Evaluate readiness score
    final score = healthSummaryAsync.when(
      data: (summary) => calculateReadiness(summary),
      loading: () => 50,
      error: (_, __) => 0,
    );
    final isReadyToTrain = score >= 60;

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

              if (healthSummaryAsync.value != null) ...[
                const CoachInsightCard(),
                const Gap(tokens.Spacing.lg),
              ],

              const ReadinessCard(),
              const Gap(tokens.Spacing.lg),

              if (healthSummaryAsync.value != null && isReadyToTrain) ...[
                const _SectionHeader(title: 'Suggested Workout'),
                const Gap(tokens.Spacing.sm),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.exercise.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppTheme.exercise.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.directions_run_rounded,
                        color: AppTheme.exercise,
                        size: 32,
                      ),
                      const Gap(16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Interval Sprints',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.label,
                              ),
                            ),
                            Text(
                              'High intensity to capitalize on recovery',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: AppTheme.secondaryLabel,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(tokens.Spacing.lg),
              ] else if (healthSummaryAsync.value != null) ...[
                const _SectionHeader(title: 'Recovery Focus'),
                const Gap(tokens.Spacing.sm),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.move.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppTheme.move.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.self_improvement_rounded,
                        color: AppTheme.move,
                        size: 32,
                      ),
                      const Gap(16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Active Recovery & Rest',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.label,
                              ),
                            ),
                            Text(
                              'Light stretching to reduce fatigue',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: AppTheme.secondaryLabel,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(tokens.Spacing.lg),
              ],

              const _SectionHeader(title: "Today's Metrics"),
              const Gap(tokens.Spacing.sm),
              healthSummaryAsync.when(
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

              if (healthSummaryAsync.value != null) ...[
                const RecoveryTrendChart(),
                const Gap(tokens.Spacing.lg),
              ],

              if (healthSummaryAsync.value == null &&
                  !healthSummaryAsync.isLoading) ...[
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
                value: summary == null
                    ? null
                    : (summary!.hrvMs?.round().toString() ?? '—'),
                unit: 'ms',
                accentColor: AppTheme.exercise,
              ),
            ),
            const Gap(tokens.Spacing.sm),
            Expanded(
              child: MetricTile(
                label: 'Resting HR',
                value: summary == null
                    ? null
                    : (summary!.rhrBpm?.round().toString() ?? '—'),
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
                value: summary == null
                    ? null
                    : (summary!.sleepHours?.toStringAsFixed(1) ?? '—'),
                unit: 'h',
                accentColor: AppTheme.stand,
              ),
            ),
            const Gap(tokens.Spacing.sm),
            Expanded(
              child: MetricTile(
                label: 'Active kcal',
                value: summary == null
                    ? null
                    : (summary!.activeCalories?.round().toString() ?? '—'),
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
