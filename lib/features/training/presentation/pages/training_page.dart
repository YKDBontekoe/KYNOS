import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kynos/app/router.dart';
import 'package:kynos/core/theme/app_theme.dart';
import 'package:kynos/core/theme/layout.dart';
import 'package:kynos/core/theme/spacing.dart' as tokens;
import 'package:kynos/features/training/presentation/widgets/past_runs_list.dart';
import 'package:kynos/features/training/presentation/widgets/training_insight_cards.dart';
import 'package:kynos/features/training/presentation/widgets/trend_cards.dart';
import 'package:kynos/features/training/presentation/widgets/weekly_stats_grid.dart';
import 'package:kynos/features/training/providers/training_insights_provider.dart';
import 'package:kynos/shared/providers/health_providers.dart';
import 'package:kynos/shared/providers/nexus_lab_provider.dart';
import 'package:kynos/shared/utils/date_label.dart';
import 'package:kynos/shared/widgets/gait_model_card.dart';
import 'package:kynos/shared/widgets/kynos_card.dart';
import 'package:kynos/shared/widgets/kynos_hero_banner.dart';
import 'package:kynos/shared/widgets/kynos_loading_line.dart';
import 'package:kynos/shared/widgets/kynos_privacy_footer.dart';
import 'package:kynos/shared/widgets/kynos_section_header.dart';

/// Training tab — weekly stats, trends, runs, and gait model.
class TrainingPage extends ConsumerWidget {
  const TrainingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(healthHistoryProvider(days: 30));
    final recentRuns = ref.watch(recentRunsProvider(days: 365, limit: 60));
    final labState = kIsWeb ? null : ref.watch(nexusLabProvider);
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
            formatDateLabel(),
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
            LayoutTokens.shellBottomPadding,
          ),
          sliver: SliverList.list(
            children: [
              const KynosHeroBanner(
                accentColor: AppTheme.exercise,
                subtitle: 'Your progress',
                title: 'TRAINING',
                caption: 'Trends, runs & gait model',
                orbAlignment: Alignment.topRight,
              ),
              const Gap(tokens.Spacing.lg),
              const KynosSectionHeader(title: 'This Week'),
              const Gap(tokens.Spacing.sm),
              history.when(
                loading: () => const KynosCard(
                  child: KynosLoadingLine(label: 'Loading weekly stats...'),
                ),
                error: (_, _) => const SizedBox.shrink(),
                data: (items) => WeeklyStatsGrid(history: items),
              ),
              const Gap(tokens.Spacing.lg),
              TrainingInsightsCards(insightsState: insightsState),
              const Gap(tokens.Spacing.lg),
              const KynosSectionHeader(title: '30-Day Trends'),
              const Gap(tokens.Spacing.sm),
              history.when(
                loading: () => const KynosCard(
                  child: KynosLoadingLine(label: 'Loading trends...'),
                ),
                error: (_, _) => const SizedBox.shrink(),
                data: (items) => TrendCards(history: items),
              ),
              const Gap(tokens.Spacing.lg),
              Row(
                children: [
                  const Expanded(child: KynosSectionHeader(title: 'Recent Runs')),
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
                error: (_, _) => const SizedBox.shrink(),
                data: (runs) => PastRunsList(runs: runs),
              ),
              const Gap(tokens.Spacing.lg),
              const KynosSectionHeader(title: 'Gait Model'),
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
              ),
              const Gap(tokens.Spacing.lg),
              const KynosPrivacyFooter(),
            ],
          ),
        ),
      ],
    );
  }
}
