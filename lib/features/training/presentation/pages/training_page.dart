import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:kynos/app/router.dart';
import 'package:kynos/core/theme/spacing.dart' as tokens;
import 'package:kynos/core/theme/theme.dart';
import 'package:kynos/domain/entities/coach/coach_seed_topic.dart';
import 'package:kynos/domain/entities/health_summary.dart';
import 'package:kynos/features/training/presentation/widgets/past_runs_list.dart';
import 'package:kynos/features/training/presentation/widgets/training_insight_cards.dart';
import 'package:kynos/features/training/presentation/widgets/weekly_stats_grid.dart';
import 'package:kynos/features/training/presentation/widgets/wellbeing_panels.dart';
import 'package:kynos/features/training/providers/training_insights_provider.dart';
import 'package:kynos/shared/providers/health_coach_providers.dart';
import 'package:kynos/shared/providers/health_providers.dart';
import 'package:kynos/shared/providers/nexus_lab_provider.dart';
import 'package:kynos/shared/utils/date_label.dart';
import 'package:kynos/shared/utils/open_coach_chat.dart';
import 'package:kynos/shared/widgets/charts/health_trend_chart.dart';
import 'package:kynos/shared/widgets/gait_model_card.dart';
import 'package:kynos/shared/widgets/kynos_card.dart';
import 'package:kynos/shared/widgets/kynos_inline_error_card.dart';
import 'package:kynos/shared/widgets/kynos_loading_line.dart';
import 'package:kynos/shared/widgets/kynos_privacy_footer.dart';
import 'package:kynos/shared/widgets/kynos_section_header.dart';

/// Training tab — weekly stats, trends, runs, and gait model.
class TrainingPage extends ConsumerStatefulWidget {
  const TrainingPage({super.key});

  @override
  ConsumerState<TrainingPage> createState() => _TrainingPageState();
}

class _TrainingPageState extends ConsumerState<TrainingPage> {
  HealthChartRange _range = HealthChartRange.month;
  HealthChartMetric _metric = HealthChartMetric.distance;

  Future<void> _refreshTraining() async {
    final days = _range.days * 2;
    ref.invalidate(healthHistoryProvider(days: days));
    ref.invalidate(recentRunsProvider(days: 365, limit: 60));
    ref.invalidate(trainingInsightsStateProvider);
    ref.invalidate(nexusLabProvider);
    ref.invalidate(dailyHealthBriefProvider);
    ref.invalidate(healthCoachDataProvider);
    await Future.wait([
      ref.read(healthHistoryProvider(days: days).future),
      ref.read(recentRunsProvider(days: 365, limit: 60).future),
      ref.read(trainingInsightsStateProvider.future),
      ref.read(nexusLabProvider.future),
      ref.read(dailyHealthBriefProvider.future),
      ref.read(healthCoachDataProvider.future),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final history = ref.watch(healthHistoryProvider(days: _range.days * 2));
    final recentRuns = ref.watch(recentRunsProvider(days: 365, limit: 60));
    final labState = kIsWeb ? null : ref.watch(nexusLabProvider);
    final insightsState = ref.watch(trainingInsightsStateProvider);
    final healthBrief = ref.watch(dailyHealthBriefProvider);
    final coachData = ref.watch(healthCoachDataProvider);

    final kynos = context.kynosTheme;

    return RefreshIndicator(
      onRefresh: _refreshTraining,
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
                Text('HEALTH', style: Theme.of(context).textTheme.labelSmall),
                const Gap(tokens.Spacing.xs),
                Text(
                  'Health',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const Gap(tokens.Spacing.xs),
                Text(
                  'Understand your sleep, recovery, movement, and lived experience',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const Gap(tokens.Spacing.lg),
                const KynosSectionHeader(title: 'Today'),
                const Gap(tokens.Spacing.sm),
                DailyHealthOverview(brief: healthBrief),
                const Gap(tokens.Spacing.lg),
                const KynosSectionHeader(title: 'Body signals'),
                const Gap(tokens.Spacing.sm),
                history.when(
                  loading: () => const KynosCard(
                    child: KynosLoadingLine(label: 'Loading weekly stats...'),
                  ),
                  error: (_, _) => KynosInlineErrorCard(
                    message: 'Could not load weekly stats.',
                    onRetry: () => ref.invalidate(
                      healthHistoryProvider(days: _range.days * 2),
                    ),
                  ),
                  data: (items) =>
                      WeeklyStatsGrid(history: _currentPeriod(items)),
                ),
                const Gap(tokens.Spacing.lg),
                const KynosSectionHeader(title: 'Progress'),
                const Gap(tokens.Spacing.sm),
                _TrendAnalysis(
                  history: history,
                  range: _range,
                  metric: _metric,
                  onRangeChanged: (value) => setState(() => _range = value),
                  onMetricChanged: (value) => setState(() => _metric = value),
                ),
                const Gap(tokens.Spacing.lg),
                TrainingInsightsCards(insightsState: insightsState),
                const Gap(tokens.Spacing.lg),
                const KynosSectionHeader(title: 'How you felt'),
                const Gap(tokens.Spacing.sm),
                coachData.when(
                  loading: () => const KynosCard(
                    child: KynosLoadingLine(label: 'Loading check-ins...'),
                  ),
                  error: (_, _) => KynosInlineErrorCard(
                    message: 'Could not load check-ins.',
                    onRetry: () => ref.invalidate(healthCoachDataProvider),
                  ),
                  data: (data) => CheckInHistoryPanel(checkIns: data.checkIns),
                ),
                const Gap(tokens.Spacing.lg),
                const KynosSectionHeader(title: 'Wellbeing experiments'),
                const Gap(tokens.Spacing.sm),
                coachData.when(
                  loading: () => const KynosCard(
                    child: KynosLoadingLine(label: 'Loading experiments...'),
                  ),
                  error: (_, _) => KynosInlineErrorCard(
                    message: 'Could not load wellbeing experiments.',
                    onRetry: () => ref.invalidate(healthCoachDataProvider),
                  ),
                  data: (data) =>
                      WellbeingExperimentsPanel(experiments: data.experiments),
                ),
                const Gap(tokens.Spacing.lg),
                Row(
                  children: [
                    const Expanded(
                      child: KynosSectionHeader(title: 'Movement & exercise'),
                    ),
                    TextButton(
                      onPressed: () => context.push(Routes.runHistory),
                      child: const Text('View all'),
                    ),
                  ],
                ),
                const Gap(tokens.Spacing.sm),
                recentRuns.when(
                  loading: () => const KynosCard(
                    child: KynosLoadingLine(label: 'Loading recent runs...'),
                  ),
                  error: (_, _) => KynosInlineErrorCard(
                    message: 'Could not load recent runs.',
                    onRetry: () => ref.invalidate(
                      recentRunsProvider(days: 365, limit: 60),
                    ),
                  ),
                  data: (runs) => PastRunsList(
                    runs: runs,
                    onAskCoach: (run, seed) => openCoachChat(
                      context,
                      ref,
                      seed: seed,
                      topic: CoachSeedTopic.run,
                      runId: run.id,
                    ),
                  ),
                ),
                const Gap(tokens.Spacing.lg),
                const KynosSectionHeader(title: 'Advanced movement analysis'),
                const Gap(tokens.Spacing.sm),
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
                      : () => ref.read(nexusLabProvider.notifier).calibrate(),
                  onAskCoach: () => openCoachChat(
                    context,
                    ref,
                    seed:
                        'Explain my gait model and what the beta coefficients mean '
                        'for my running form.',
                    topic: CoachSeedTopic.gait,
                  ),
                ),
                const Gap(tokens.Spacing.lg),
                TextButton(
                  onPressed: () => context.push(Routes.nexusLab),
                  child: const Text('Open Nexus Lab'),
                ),
                const Gap(tokens.Spacing.lg),
                const KynosPrivacyFooter(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<HealthSummary> _currentPeriod(List<HealthSummary> items) {
    final cutoff = DateTime.now().subtract(Duration(days: _range.days));
    return items.where((item) => item.date.isAfter(cutoff)).toList();
  }
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
          Wrap(
            spacing: tokens.Spacing.xs,
            children: HealthChartRange.values
                .map(
                  (item) => ChoiceChip(
                    label: Text(item.label),
                    selected: item == range,
                    onSelected: (_) => onRangeChanged(item),
                  ),
                )
                .toList(),
          ),
          const Gap(tokens.Spacing.sm),
          DropdownButton<HealthChartMetric>(
            value: metric,
            isExpanded: true,
            underline: const SizedBox.shrink(),
            onChanged: (value) {
              if (value != null) onMetricChanged(value);
            },
            items: HealthChartMetric.values
                .map(
                  (item) =>
                      DropdownMenuItem(value: item, child: Text(item.label)),
                )
                .toList(),
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
