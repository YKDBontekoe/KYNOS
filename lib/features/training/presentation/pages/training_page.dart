import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:kynos/app/router.dart';
import 'package:kynos/core/theme/spacing.dart' as tokens;
import 'package:kynos/core/theme/theme.dart';
import 'package:kynos/domain/entities/coach/coach_seed_topic.dart';
import 'package:kynos/domain/entities/dashboard/dashboard_summary.dart';
import 'package:kynos/domain/entities/health_summary.dart';
import 'package:kynos/domain/utils/readiness_score.dart';
import 'package:kynos/domain/utils/weekly_momentum.dart';
import 'package:kynos/features/dashboard/presentation/widgets/coach_insight_card.dart';
import 'package:kynos/features/dashboard/presentation/widgets/connect_healthkit_card.dart';
import 'package:kynos/features/dashboard/presentation/widgets/last_run_preview.dart';
import 'package:kynos/features/dashboard/presentation/widgets/readiness_card.dart';
import 'package:kynos/features/dashboard/presentation/widgets/week_momentum_card.dart';
import 'package:kynos/features/training/presentation/widgets/past_runs_list.dart';
import 'package:kynos/features/training/presentation/widgets/weekly_stats_grid.dart';
import 'package:kynos/features/training/presentation/widgets/wellbeing_panels.dart';
import 'package:kynos/shared/providers/dashboard_summary_provider.dart';
import 'package:kynos/shared/providers/health_coach_providers.dart';
import 'package:kynos/shared/providers/health_providers.dart';
import 'package:kynos/shared/providers/nexus_lab_provider.dart';
import 'package:kynos/shared/providers/today_insights_provider.dart';
import 'package:kynos/shared/utils/open_coach_chat.dart';
import 'package:kynos/shared/widgets/charts/health_trend_chart.dart';
import 'package:kynos/shared/widgets/gait_model_card.dart';
import 'package:kynos/shared/widgets/kynos_card.dart';
import 'package:kynos/shared/widgets/kynos_chip.dart';
import 'package:kynos/shared/widgets/kynos_collapsible_section.dart';
import 'package:kynos/shared/widgets/kynos_inline_error_card.dart';
import 'package:kynos/shared/widgets/kynos_loading_line.dart';
import 'package:kynos/shared/widgets/kynos_page_header.dart';
import 'package:kynos/shared/widgets/kynos_privacy_footer.dart';
import 'package:kynos/shared/widgets/kynos_section_header.dart';
import 'package:kynos/shared/widgets/kynos_section_jump_bar.dart';
import 'package:kynos/shared/widgets/kynos_segmented_control.dart';

/// Unified Health hub — merges dashboard "today" surfaces with training detail.
class TrainingPage extends ConsumerStatefulWidget {
  const TrainingPage({super.key});

  @override
  ConsumerState<TrainingPage> createState() => _TrainingPageState();
}

class _TrainingPageState extends ConsumerState<TrainingPage> {
  final _scrollController = ScrollController();
  final _sectionKeys = List.generate(5, (_) => GlobalKey());
  int _jumpIndex = 0;
  HealthChartRange _range = HealthChartRange.month;
  HealthChartMetric _metric = HealthChartMetric.recovery;

  static const _jumpSections = [
    'Today',
    'Week',
    'Trends',
    'Runs',
    'More',
  ];

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _refreshHealthHub() async {
    final days = _range.days * 2;
    ref.invalidate(healthSummaryProvider);
    ref.invalidate(todayInsightsStateProvider);
    ref.invalidate(healthHistoryProvider(days: 28));
    ref.invalidate(healthHistoryProvider(days: days));
    ref.invalidate(recentRunsProvider(days: 365, limit: 60));
    ref.invalidate(recentRunsProvider(days: 30, limit: 3));
    ref.invalidate(dashboardSummaryProvider);
    ref.invalidate(nexusLabProvider);
    ref.invalidate(dailyHealthBriefProvider);
    ref.invalidate(healthCoachDataProvider);
    await Future.wait([
      ref.read(healthSummaryProvider.future),
      ref.read(todayInsightsStateProvider.future),
      ref.read(healthHistoryProvider(days: days).future),
      ref.read(healthHistoryProvider(days: 28).future),
      ref.read(recentRunsProvider(days: 365, limit: 60).future),
      ref.read(recentRunsProvider(days: 30, limit: 3).future),
      ref.read(dashboardSummaryProvider.future),
      ref.read(dailyHealthBriefProvider.future),
      ref.read(healthCoachDataProvider.future),
    ]);
  }

  void _scrollToSection(int index) {
    setState(() => _jumpIndex = index);
    final context = _sectionKeys[index].currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: Motion.medium,
        curve: Motion.curve,
        alignment: 0.05,
      );
    }
  }

  void _openCoachChat({
    String? seedMessage,
    CoachSeedTopic topic = CoachSeedTopic.general,
  }) {
    openCoachChat(context, ref, seed: seedMessage, topic: topic);
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 5) return 'Good night';
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    if (h < 21) return 'Good evening';
    return 'Good night';
  }

  String _statusSubtitle({
    required HealthSummary? summary,
    required DashboardSummary? dash,
  }) {
    final parts = <String>[];
    final score = readinessScore(summary);
    if (score > 0) {
      parts.add(readinessSummaryBrief(score).split('.').first);
    }
    if (dash != null && dash.runStreak > 0) {
      parts.add('${dash.runStreak}-day streak');
    }
    if (parts.isEmpty) {
      return 'Sleep, recovery, movement, and how you feel';
    }
    return parts.join(' · ');
  }

  bool _shouldShowWeeklyGoalCoachNudge(WeeklyMomentum? momentum) {
    if (momentum == null) return false;
    return DateTime.now().weekday >= DateTime.wednesday &&
        momentum.distanceGoalProgress < 0.5;
  }

  List<HealthSummary> _currentPeriod(List<HealthSummary> items) {
    final cutoff = DateTime.now().subtract(Duration(days: _range.days));
    return items.where((item) => item.date.isAfter(cutoff)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final summary = ref.watch(healthSummaryProvider);
    final todayInsights = ref.watch(todayInsightsStateProvider);
    final history = ref.watch(healthHistoryProvider(days: _range.days * 2));
    final weekHistory = ref.watch(healthHistoryProvider(days: 28));
    final recentRunsPreview = ref.watch(recentRunsProvider(days: 30, limit: 3));
    final recentRuns = ref.watch(recentRunsProvider(days: 365, limit: 60));
    final dashboardSummaryAsync = ref.watch(dashboardSummaryProvider);
    final dash = dashboardSummaryAsync.value;
    final healthBrief = ref.watch(dailyHealthBriefProvider);
    final coachData = ref.watch(healthCoachDataProvider);
    final labState = kIsWeb ? null : ref.watch(nexusLabProvider);
    final showConnectCard =
        !kIsWeb && summary.hasValue && summary.requireValue == null;

    return RefreshIndicator(
      onRefresh: _refreshHealthHub,
      child: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          KynosPageHeader(
            greeting: _greeting(),
            title: 'Health',
            subtitle: _statusSubtitle(summary: summary.value, dash: dash),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _JumpBarDelegate(
              child: KynosSectionJumpBar(
                sections: _jumpSections,
                selectedIndex: _jumpIndex,
                onSelected: _scrollToSection,
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              tokens.Spacing.md,
              tokens.Spacing.sm,
              tokens.Spacing.md,
              LayoutTokens.shellBottomPadding(context),
            ),
            sliver: SliverList.list(
              children: [
                _SectionAnchor(
                  key: _sectionKeys[0],
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const KynosSectionHeader(title: 'Today'),
                      const Gap(tokens.Spacing.sm),
                      ReadinessCard(
                        summaryAsync: summary,
                        todayInsightsState: todayInsights,
                        onRetry: _refreshHealthHub,
                      ),
                      const Gap(tokens.Spacing.md),
                      DailyHealthOverview(brief: healthBrief),
                    ],
                  ),
                ),
                const Gap(tokens.Spacing.xl),
                _SectionAnchor(
                  key: _sectionKeys[1],
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const KynosSectionHeader(title: 'This week'),
                      const Gap(tokens.Spacing.sm),
                      WeekMomentumCard(
                        momentum: dash?.weeklyMomentum,
                        isLoading: weekHistory.isLoading ||
                            dashboardSummaryAsync.isLoading,
                        onImportRun: () => context.push(Routes.healthImport),
                        onAskCoach: _shouldShowWeeklyGoalCoachNudge(
                          dash?.weeklyMomentum,
                        )
                            ? () => _openCoachChat(
                                  seedMessage:
                                      'I am behind on my weekly distance goal. '
                                      'Help me plan the rest of the week.',
                                  topic: CoachSeedTopic.weeklyGoal,
                                )
                            : null,
                      ),
                    ],
                  ),
                ),
                const Gap(tokens.Spacing.xl),
                _SectionAnchor(
                  key: _sectionKeys[2],
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const KynosSectionHeader(title: 'Body signals'),
                      const Gap(tokens.Spacing.sm),
                      history.when(
                        loading: () => const KynosCard(
                          child: KynosLoadingLine(
                            label: 'Loading weekly stats...',
                          ),
                        ),
                        error: (_, _) => KynosInlineErrorCard(
                          message: 'Could not load weekly stats.',
                          onRetry: () => ref.invalidate(
                            healthHistoryProvider(days: _range.days * 2),
                          ),
                        ),
                        data: (items) => WeeklyStatsGrid(
                          history: _currentPeriod(items),
                        ),
                      ),
                      const Gap(tokens.Spacing.lg),
                      const KynosSectionHeader(title: 'Trends'),
                      const Gap(tokens.Spacing.sm),
                      _TrendAnalysis(
                        history: history,
                        range: _range,
                        metric: _metric,
                        onRangeChanged: (value) =>
                            setState(() => _range = value),
                        onMetricChanged: (value) =>
                            setState(() => _metric = value),
                      ),
                      const Gap(tokens.Spacing.lg),
                      CoachInsightCard(
                        todayInsightsState: todayInsights,
                        history: history.value ?? const [],
                        onAskCoach: () => _openCoachChat(
                          seedMessage:
                              'Based on my readiness today, what should I '
                              'prioritise in training?',
                          topic: CoachSeedTopic.general,
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(tokens.Spacing.xl),
                _SectionAnchor(
                  key: _sectionKeys[3],
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: KynosSectionHeader(title: 'Recent runs'),
                          ),
                          TextButton(
                            onPressed: () => context.push(Routes.runHistory),
                            child: const Text('View all'),
                          ),
                        ],
                      ),
                      const Gap(tokens.Spacing.sm),
                      LastRunPreview(runsAsync: recentRunsPreview),
                      const Gap(tokens.Spacing.md),
                      recentRuns.when(
                        loading: () => const KynosCard(
                          child: KynosLoadingLine(
                            label: 'Loading run history...',
                          ),
                        ),
                        error: (_, _) => KynosInlineErrorCard(
                          message: 'Could not load recent runs.',
                          onRetry: () => ref.invalidate(
                            recentRunsProvider(days: 365, limit: 60),
                          ),
                        ),
                        data: (runs) => PastRunsList(
                          runs: runs.take(5).toList(),
                          onAskCoach: (run, seed) => openCoachChat(
                            context,
                            ref,
                            seed: seed,
                            topic: CoachSeedTopic.run,
                            runId: run.id,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(tokens.Spacing.xl),
                _SectionAnchor(
                  key: _sectionKeys[4],
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      KynosCollapsibleSection(
                        title: 'How you felt',
                        subtitle: 'Daily check-ins and lived experience',
                        child: coachData.when(
                          loading: () => const KynosLoadingLine(
                            label: 'Loading check-ins...',
                          ),
                          error: (_, _) => KynosInlineErrorCard(
                            message: 'Could not load check-ins.',
                            onRetry: () =>
                                ref.invalidate(healthCoachDataProvider),
                          ),
                          data: (data) =>
                              CheckInHistoryPanel(checkIns: data.checkIns),
                        ),
                      ),
                      const Gap(tokens.Spacing.md),
                      coachData.when(
                        data: (data) {
                          if (data.experiments.isEmpty) {
                            return const SizedBox.shrink();
                          }
                          return KynosCollapsibleSection(
                            title: 'Wellbeing experiments',
                            initiallyExpanded: true,
                            child: WellbeingExperimentsPanel(
                              experiments: data.experiments,
                            ),
                          );
                        },
                        loading: () => const SizedBox.shrink(),
                        error: (_, _) => const SizedBox.shrink(),
                      ),
                      const Gap(tokens.Spacing.md),
                      KynosCollapsibleSection(
                        title: 'Advanced analysis',
                        subtitle: 'Gait model and Nexus Lab',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GaitModelCardAsync(
                              labState: labState?.when(
                                loading: () => const AsyncLoading(),
                                error: AsyncError.new,
                                data: (state) => AsyncData((
                                  coefficients: state.coefficients,
                                  calibratedAt: state.calibratedAt,
                                )),
                              ),
                              onCalibrate: kIsWeb
                                  ? null
                                  : () => ref
                                      .read(nexusLabProvider.notifier)
                                      .calibrate(),
                              onAskCoach: () => _openCoachChat(
                                seedMessage:
                                    'Explain my gait model and what the beta '
                                    'coefficients mean for my running form.',
                                topic: CoachSeedTopic.gait,
                              ),
                            ),
                            const Gap(tokens.Spacing.sm),
                            KynosCard(
                              onTap: () => context.push(Routes.nexusLab),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.science_outlined,
                                    color: context.kynosTheme.purple,
                                  ),
                                  const Gap(tokens.Spacing.sm),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Nexus Lab',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall,
                                        ),
                                        Text(
                                          'Calibrate biomechanics coefficients',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: context
                                                    .kynosTheme
                                                    .secondaryLabel,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  KynosChip.accent(
                                    label: 'Beta',
                                    color: context.kynosTheme.purple,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (showConnectCard) ...[
                  const Gap(tokens.Spacing.lg),
                  const ConnectHealthkitCard(),
                ],
                const Gap(tokens.Spacing.lg),
                const KynosPrivacyFooter(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionAnchor extends StatelessWidget {
  const _SectionAnchor({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => child;
}

class _JumpBarDelegate extends SliverPersistentHeaderDelegate {
  _JumpBarDelegate({required this.child});

  final Widget child;

  @override
  double get minExtent => 52;

  @override
  double get maxExtent => 52;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final kynos = context.kynosTheme;
    return ColoredBox(
      color: kynos.background.withValues(
        alpha: overlapsContent ? 0.96 : 1,
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: tokens.Spacing.xs),
          child: child,
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _JumpBarDelegate oldDelegate) =>
      oldDelegate.child != child;
}

class _TrendAnalysis extends StatelessWidget {
  const _TrendAnalysis({
    required this.history,
    required this.range,
    required this.metric,
    required this.onRangeChanged,
    required this.onMetricChanged,
  });

  final AsyncValue<List<HealthSummary>> history;
  final HealthChartRange range;
  final HealthChartMetric metric;
  final ValueChanged<HealthChartRange> onRangeChanged;
  final ValueChanged<HealthChartMetric> onMetricChanged;

  @override
  Widget build(BuildContext context) {
    return KynosCard(
      padding: const EdgeInsets.all(tokens.Spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          KynosSegmentedControl<HealthChartRange>(
            segments: HealthChartRange.values,
            selected: range,
            onChanged: onRangeChanged,
            labelBuilder: (value) => value.label,
          ),
          const Gap(tokens.Spacing.sm),
          KynosSegmentedControl<HealthChartMetric>(
            segments: const [
              HealthChartMetric.recovery,
              HealthChartMetric.distance,
              HealthChartMetric.sleep,
              HealthChartMetric.restingPulse,
            ],
            selected: metric,
            onChanged: onMetricChanged,
            labelBuilder: (value) => value.label,
          ),
          const Gap(tokens.Spacing.sm),
          SizedBox(
            height: 250,
            child: history.when(
              loading: () =>
                  const KynosLoadingLine(label: 'Loading progress...'),
              error: (_, _) => const Text('Could not load progress data.'),
              data: (items) => HealthTrendChart(
                history: items,
                comparisonHistory: items.where((item) {
                  final currentCutoff = DateTime.now().subtract(
                    Duration(days: range.days),
                  );
                  return item.date.isBefore(currentCutoff);
                }).toList(),
                metric: metric,
                range: range,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
