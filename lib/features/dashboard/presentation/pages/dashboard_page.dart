import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:kynos/app/router.dart';
import 'package:kynos/core/theme/spacing.dart' as tokens;
import 'package:kynos/core/theme/theme.dart';
import 'package:kynos/domain/entities/dashboard/dashboard_summary.dart';
import 'package:kynos/domain/entities/health_summary.dart';
import 'package:kynos/domain/utils/readiness_score.dart';
import 'package:kynos/features/coach_chat/providers/coach_chat_seed_provider.dart';
import 'package:kynos/features/dashboard/presentation/widgets/character_glance_card.dart';
import 'package:kynos/features/dashboard/presentation/widgets/coach_insight_card.dart';
import 'package:kynos/features/dashboard/presentation/widgets/connect_healthkit_card.dart';
import 'package:kynos/features/dashboard/presentation/widgets/daily_quest_teaser.dart';
import 'package:kynos/features/dashboard/presentation/widgets/dashboard_header_sliver.dart';
import 'package:kynos/features/dashboard/presentation/widgets/gait_teaser_card.dart';
import 'package:kynos/features/dashboard/presentation/widgets/health_metrics_grid.dart';
import 'package:kynos/features/dashboard/presentation/widgets/last_run_preview.dart';
import 'package:kynos/features/dashboard/presentation/widgets/readiness_card.dart';
import 'package:kynos/features/dashboard/presentation/widgets/trend_carousel.dart';
import 'package:kynos/features/dashboard/presentation/widgets/week_momentum_card.dart';
import 'package:kynos/features/dashboard/providers/dashboard_summary_provider.dart';
import 'package:kynos/features/dashboard/providers/post_run_debrief_provider.dart';
import 'package:kynos/features/training/providers/training_insights_provider.dart';
import 'package:kynos/features/dashboard/providers/today_insights_provider.dart';
import 'package:kynos/shared/providers/character_providers.dart';
import 'package:kynos/shared/providers/daily_quests_provider.dart';
import 'package:kynos/shared/providers/health_providers.dart';
import 'package:kynos/shared/providers/nexus_lab_provider.dart';
import 'package:kynos/shared/widgets/kynos_card.dart';
import 'package:kynos/shared/widgets/kynos_chip.dart';
import 'package:kynos/shared/widgets/kynos_privacy_footer.dart';
import 'package:kynos/shared/widgets/kynos_section_row.dart';

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
    ref.invalidate(trainingInsightsStateProvider);
    ref.invalidate(healthHistoryProvider(days: 28));
    ref.invalidate(healthHistoryProvider(days: 30));
    ref.invalidate(recentRunsProvider(days: 30, limit: 3));
    ref.invalidate(dailyQuestsProvider);
    ref.invalidate(dashboardSummaryProvider);
    ref.invalidate(runnerCharacterProvider);
    ref.invalidate(nexusLabProvider);
    ref.invalidate(postRunDebriefProvider);
    await Future.wait([
      ref.read(healthSummaryProvider.future),
      ref.read(todayInsightsStateProvider.future),
      ref.read(trainingInsightsStateProvider.future),
      ref.read(healthHistoryProvider(days: 28).future),
      ref.read(recentRunsProvider(days: 30, limit: 3).future),
      ref.read(dailyQuestsProvider.future),
      ref.read(dashboardSummaryProvider.future),
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
    final character = dash?.character;
    if (character != null) {
      final className = character.characterClass.name.replaceFirst('The ', '');
      parts.add('Level ${character.level} $className');
    }
    if (parts.isEmpty) return 'Your AI running coach';
    return parts.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    final kynos = context.kynosTheme;
    final summary = ref.watch(healthSummaryProvider);
    final todayInsightsState = ref.watch(todayInsightsStateProvider);
    final loadHistory = ref.watch(healthHistoryProvider(days: 28));
    final weekHistory = _last7Days(loadHistory.value ?? const []);
    final recentRuns = ref.watch(recentRunsProvider(days: 30, limit: 3));
    final dailyQuests = ref.watch(dailyQuestsProvider);
    final dashboardSummaryAsync = ref.watch(dashboardSummaryProvider);
    final dash = dashboardSummaryAsync.value;
    final showConnectCard = !kIsWeb &&
        summary.hasValue &&
        summary.requireValue == null;

    ref.listen(postRunDebriefProvider, (prev, next) {
      next.whenOrNull(
        data: (data) {
          if (data == null || !mounted) return;
          final debriefText =
              'Run debrief: ${data.debrief.highlight} (+${data.xpAmount} XP)';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(debriefText),
              action: SnackBarAction(
                label: 'Read debrief',
                onPressed: () {
                  ref.read(coachChatSeedProvider.notifier).setSeed(
                        'Here is my post-run debrief: ${data.debrief.highlight}. '
                        'What should I focus on in recovery?',
                      );
                  context.push(Routes.coachChat);
                  ref.read(postRunDebriefProvider.notifier).dismiss();
                },
              ),
              duration: const Duration(seconds: 8),
            ),
          );
        },
        error: (error, _) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Could not generate your post-run debrief. Pull to refresh to retry.',
              ),
              action: SnackBarAction(
                label: 'Dismiss',
                onPressed: () =>
                    ref.read(postRunDebriefProvider.notifier).dismiss(),
              ),
            ),
          );
        },
      );
    });

    return RefreshIndicator(
      onRefresh: _refreshDashboard,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          DashboardHeaderSliver(
            greeting: _greeting(),
            subtitle: _statusSubtitle(summary: summary.value, dash: dash),
            onAskCoach: () => _openCoachChat(),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              tokens.Spacing.md,
              tokens.Spacing.lg,
              tokens.Spacing.md,
              LayoutTokens.shellBottomPadding,
            ),
            sliver: SliverList.list(
              children: [
                ReadinessCard(
                  summaryAsync: summary,
                  todayInsightsState: todayInsightsState,
                  onRetry: _refreshDashboard,
                ),
                const Gap(tokens.Spacing.xl),
                KynosSectionRow(
                  title: 'This Week',
                  actionLabel: widget.onViewTraining != null ? 'See all' : null,
                  onAction: widget.onViewTraining,
                ),
                const Gap(tokens.Spacing.md),
                WeekMomentumCard(
                  momentum: dash?.weeklyMomentum,
                  isLoading:
                      loadHistory.isLoading || dashboardSummaryAsync.isLoading,
                  onImportRun: () => context.push(Routes.healthImport),
                ),
                const Gap(tokens.Spacing.xl),
                const KynosSectionRow(title: 'Highlights'),
                const Gap(tokens.Spacing.md),
                HealthMetricsGrid(
                  summary: summary.value,
                  dashboardSummary: dash,
                  isLoading: summary.isLoading,
                  onViewTraining: widget.onViewTraining,
                  onAskCoach: (seed) => _openCoachChat(seedMessage: seed),
                  section: HealthMetricsSection.highlights,
                ),
                const Gap(tokens.Spacing.xl),
                const KynosSectionRow(title: 'Trends'),
                const Gap(tokens.Spacing.md),
                TrendCarousel(history: weekHistory),
                const Gap(tokens.Spacing.xl),
                const KynosSectionRow(title: 'Coach Insight'),
                const Gap(tokens.Spacing.md),
                CoachInsightCard(
                  todayInsightsState: todayInsightsState,
                  history: loadHistory.value ?? const <HealthSummary>[],
                  onAskCoach: () => _openCoachChat(
                    seedMessage: _coachSeedFromInsights(
                      todayInsightsState.value,
                    ),
                  ),
                ),
                const Gap(tokens.Spacing.xl),
                const KynosSectionRow(title: 'Recent Runs'),
                const Gap(tokens.Spacing.md),
                LastRunPreview(runsAsync: recentRuns),
                const Gap(tokens.Spacing.xl),
                const KynosSectionRow(title: 'Progress'),
                const Gap(tokens.Spacing.md),
                if (dash?.streakNudge != null) ...[
                  KynosCard(
                    padding: const EdgeInsets.all(tokens.Spacing.lg),
                    child: Row(
                      children: [
                        Icon(Icons.local_fire_department, color: kynos.energy),
                        const Gap(tokens.Spacing.sm),
                        Expanded(
                          child: Text(
                            dash!.streakNudge!,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Gap(tokens.Spacing.md),
                ],
                if (dash?.character != null) ...[
                  CharacterGlanceCard(
                    character: dash!.character!,
                    onViewCharacter: widget.onViewCharacter,
                  ),
                  const Gap(tokens.Spacing.md),
                ],
                DailyQuestTeaser(
                  questsAsync: dailyQuests,
                  onViewCharacter: widget.onViewCharacter,
                ),
                if (dash != null && dash.personalBestCallouts.isNotEmpty) ...[
                  const Gap(tokens.Spacing.md),
                  Wrap(
                    spacing: tokens.Spacing.sm,
                    runSpacing: tokens.Spacing.sm,
                    children: dash.personalBestCallouts
                        .map(
                          (callout) => KynosChip.accent(
                            label: callout,
                            color: kynos.willpower,
                          ),
                        )
                        .toList(),
                  ),
                ],
                if (dailyQuests.value?.isNotEmpty ?? false)
                  const Gap(tokens.Spacing.xl),
                const KynosSectionRow(title: 'Activity'),
                const Gap(tokens.Spacing.md),
                HealthMetricsGrid(
                  summary: summary.value,
                  dashboardSummary: dash,
                  isLoading: summary.isLoading,
                  onViewTraining: widget.onViewTraining,
                  onAskCoach: (seed) => _openCoachChat(seedMessage: seed),
                  section: HealthMetricsSection.activity,
                ),
                const Gap(tokens.Spacing.xl),
                if (!kIsWeb && dash?.isGaitCalibrated == true) ...[
                  GaitTeaserCard(
                    coefficients: dash!.gaitCoefficients,
                    summary: summary.value,
                    calibratedAt: dash.gaitCalibratedAt,
                    onViewTraining: widget.onViewTraining,
                  ),
                  const Gap(tokens.Spacing.xl),
                ],
                if (showConnectCard) const ConnectHealthkitCard(),
                if (showConnectCard) const Gap(tokens.Spacing.xl),
                const KynosPrivacyFooter(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
