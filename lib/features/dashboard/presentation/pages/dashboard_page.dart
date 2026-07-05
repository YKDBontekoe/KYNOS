import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:kynos/app/router.dart';
import 'package:kynos/core/theme/spacing.dart' as tokens;
import 'package:kynos/core/theme/theme.dart';
import 'package:kynos/domain/entities/health_summary.dart';
import 'package:kynos/features/coach_chat/providers/coach_chat_seed_provider.dart';
import 'package:kynos/features/dashboard/presentation/widgets/acwr_guardrail_card.dart';
import 'package:kynos/features/dashboard/presentation/widgets/connect_healthkit_card.dart';
import 'package:kynos/features/dashboard/presentation/widgets/daily_quest_teaser.dart';
import 'package:kynos/features/dashboard/presentation/widgets/health_metrics_grid.dart';
import 'package:kynos/features/dashboard/presentation/widgets/last_run_preview.dart';
import 'package:kynos/features/dashboard/presentation/widgets/readiness_card.dart';
import 'package:kynos/features/dashboard/presentation/widgets/today_insight_cards.dart';
import 'package:kynos/features/dashboard/presentation/widgets/weekly_snapshot_row.dart';
import 'package:kynos/features/dashboard/providers/post_run_debrief_provider.dart';
import 'package:kynos/features/dashboard/providers/today_insights_provider.dart';
import 'package:kynos/shared/providers/daily_quests_provider.dart';
import 'package:kynos/shared/providers/health_providers.dart';
import 'package:kynos/shared/utils/date_label.dart';
import 'package:kynos/shared/widgets/kynos_card.dart';
import 'package:kynos/shared/widgets/kynos_hero_banner.dart';
import 'package:kynos/shared/widgets/kynos_privacy_footer.dart';
import 'package:kynos/shared/widgets/kynos_section_header.dart';

/// Today tab — readiness, AI insight, and today's health metrics.
class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({
    super.key,
    this.onViewTraining,
    this.onViewCharacter,
  });

  final VoidCallback? onViewTraining;
  final VoidCallback? onViewCharacter;

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(postRunDebriefProvider.notifier).checkLatestRun();
    });
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 5) return 'Good night';
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    if (h < 21) return 'Good evening';
    return 'Good night';
  }

  Future<void> _refreshDashboard() async {
    ref.invalidate(healthSummaryProvider);
    ref.invalidate(todayInsightsStateProvider);
    ref.invalidate(healthHistoryProvider(days: 28));
    ref.invalidate(recentRunsProvider(days: 30, limit: 1));
    ref.invalidate(dailyQuestsProvider);
    await Future.wait([
      ref.read(healthSummaryProvider.future),
      ref.read(todayInsightsStateProvider.future),
      ref.read(healthHistoryProvider(days: 28).future),
      ref.read(recentRunsProvider(days: 30, limit: 1).future),
      ref.read(dailyQuestsProvider.future),
    ]);
  }

  List<HealthSummary> _last7Days(List<HealthSummary> history) {
    final sorted = List<HealthSummary>.from(history)
      ..sort((a, b) => b.date.compareTo(a.date));
    return sorted.take(7).toList();
  }

  void _openCoachChat({String? seedMessage}) {
    if (seedMessage != null && seedMessage.isNotEmpty) {
      ref.read(coachChatSeedProvider.notifier).setSeed(seedMessage);
    }
    context.push(Routes.coachChat);
  }

  String? _coachSeedFromInsights(TodayInsightsState? state) {
    final insights = state?.insights;
    if (insights == null) return null;

    final risk = insights.riskFlags.isNotEmpty
        ? insights.riskFlags.first
        : 'No major risks flagged';
    return 'Based on my readiness today: ${insights.readinessBrief}. '
        'Top risk: $risk. ${insights.actionNow} '
        'What should I prioritise in training today?';
  }

  @override
  Widget build(BuildContext context) {
    final kynos = context.kynosTheme;
    final summary = ref.watch(healthSummaryProvider);
    final todayInsightsState = ref.watch(todayInsightsStateProvider);
    final loadHistory = ref.watch(healthHistoryProvider(days: 28));
    final weekHistory = _last7Days(loadHistory.value ?? const []);
    final recentRuns = ref.watch(recentRunsProvider(days: 30, limit: 1));
    final dailyQuests = ref.watch(dailyQuestsProvider);
    final showConnectCard = !kIsWeb &&
        summary.hasValue &&
        summary.requireValue == null;
    final showHealthError = !kIsWeb && summary.hasError;

    ref.listen(postRunDebriefProvider, (prev, next) {
      final data = next.value;
      if (data == null || !mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Run debrief: ${data.debrief.highlight} (+${data.xpAmount} XP)',
          ),
          action: SnackBarAction(
            label: 'Dismiss',
            onPressed: () =>
                ref.read(postRunDebriefProvider.notifier).dismiss(),
          ),
          duration: const Duration(seconds: 8),
        ),
      );
    });

    return RefreshIndicator(
      onRefresh: _refreshDashboard,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          SliverAppBar(
            backgroundColor: kynos.background,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            pinned: true,
            toolbarHeight: 56,
            titleSpacing: 20,
            title: Text(
              formatDateLabel(),
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: kynos.tertiaryLabel,
                    letterSpacing: 0.2,
                  ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () => context.push(Routes.settings),
                tooltip: 'Settings',
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              tokens.Spacing.md,
              0,
              tokens.Spacing.md,
              LayoutTokens.shellBottomPadding,
            ),
            sliver: SliverList.list(
              children: [
                KynosHeroBanner(
                  accentColor: kynos.stand,
                  subtitle: _greeting(),
                  title: 'KYNOS',
                  caption: 'Your AI running coach',
                  actionLabel: 'Ask Coach',
                  onActionTap: () => _openCoachChat(),
                ),
                const Gap(tokens.Spacing.lg),
                ReadinessCard(
                  summaryAsync: summary,
                  todayInsightsState: todayInsightsState,
                  history: weekHistory,
                ),
                const Gap(tokens.Spacing.md),
                AcwrGuardrailCard(
                  history: loadHistory.value ?? const <HealthSummary>[],
                ),
                const Gap(tokens.Spacing.md),
                Row(
                  children: [
                    const Expanded(
                      child: KynosSectionHeader(title: 'This Week'),
                    ),
                    if (widget.onViewTraining != null)
                      TextButton(
                        onPressed: widget.onViewTraining,
                        style: TextButton.styleFrom(
                          minimumSize: Size.zero,
                          padding: EdgeInsets.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text('See all'),
                      ),
                  ],
                ),
                const Gap(tokens.Spacing.sm),
                WeeklySnapshotRow(
                  history: weekHistory,
                  isLoading: loadHistory.isLoading,
                ),
                const Gap(tokens.Spacing.lg),
                TodayInsightCards(
                  todayInsightsState: todayInsightsState,
                  onAskCoach: () => _openCoachChat(
                    seedMessage: _coachSeedFromInsights(
                      todayInsightsState.value,
                    ),
                  ),
                ),
                const Gap(tokens.Spacing.lg),
                DailyQuestTeaser(
                  questsAsync: dailyQuests,
                  onViewCharacter: widget.onViewCharacter,
                ),
                if (dailyQuests.value?.isNotEmpty ?? false)
                  const Gap(tokens.Spacing.lg),
                const KynosSectionHeader(title: 'Last Run'),
                const Gap(tokens.Spacing.sm),
                LastRunPreview(runsAsync: recentRuns),
                const Gap(tokens.Spacing.lg),
                const KynosSectionHeader(title: "Today's Metrics"),
                const Gap(tokens.Spacing.sm),
                HealthMetricsGrid(
                  summary: summary.value,
                  isLoading: summary.isLoading,
                ),
                const Gap(tokens.Spacing.lg),
                if (showHealthError) ...[
                  KynosCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Could not load health data.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const Gap(tokens.Spacing.sm),
                        TextButton(
                          onPressed: _refreshDashboard,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                  const Gap(tokens.Spacing.lg),
                ],
                if (showConnectCard) const ConnectHealthkitCard(),
                if (showConnectCard) const Gap(tokens.Spacing.lg),
                const KynosPrivacyFooter(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
