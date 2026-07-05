import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:kynos/app/router.dart';
import 'package:kynos/core/theme/spacing.dart' as tokens;
import 'package:kynos/core/theme/theme.dart';
import 'package:kynos/features/coach_chat/providers/coach_chat_seed_provider.dart';
import 'package:kynos/features/dashboard/presentation/widgets/connect_healthkit_card.dart';
import 'package:kynos/features/dashboard/presentation/widgets/daily_quest_teaser.dart';
import 'package:kynos/features/dashboard/presentation/widgets/health_metrics_grid.dart';
import 'package:kynos/features/dashboard/presentation/widgets/last_run_preview.dart';
import 'package:kynos/features/dashboard/presentation/widgets/readiness_card.dart';
import 'package:kynos/features/dashboard/presentation/widgets/today_insight_cards.dart';
import 'package:kynos/features/dashboard/presentation/widgets/weekly_snapshot_row.dart';
import 'package:kynos/features/dashboard/providers/today_insights_provider.dart';
import 'package:kynos/shared/providers/daily_quests_provider.dart';
import 'package:kynos/shared/providers/health_providers.dart';
import 'package:kynos/shared/utils/date_label.dart';
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
    ref.invalidate(healthHistoryProvider);
    ref.invalidate(recentRunsProvider);
    ref.invalidate(dailyQuestsProvider);
    await Future.wait([
      ref.read(healthSummaryProvider.future),
      ref.read(todayInsightsStateProvider.future),
    ]);
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
    final weekHistory = ref.watch(healthHistoryProvider(days: 7));
    final recentRuns = ref.watch(recentRunsProvider(days: 30, limit: 1));
    final dailyQuests = ref.watch(dailyQuestsProvider);
    final showConnectCard =
        !kIsWeb && summary.value == null && !summary.isLoading;

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
                  history: weekHistory.value ?? const [],
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
                  history: weekHistory.value ?? const [],
                  isLoading: weekHistory.isLoading,
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
