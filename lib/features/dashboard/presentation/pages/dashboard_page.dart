import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kynos/core/theme/app_theme.dart';
import 'package:kynos/core/theme/layout.dart';
import 'package:kynos/core/theme/spacing.dart' as tokens;
import 'package:kynos/features/dashboard/presentation/widgets/connect_healthkit_card.dart';
import 'package:kynos/features/dashboard/presentation/widgets/health_metrics_grid.dart';
import 'package:kynos/features/dashboard/presentation/widgets/readiness_card.dart';
import 'package:kynos/features/dashboard/presentation/widgets/today_insight_cards.dart';
import 'package:kynos/features/dashboard/providers/today_insights_provider.dart';
import 'package:kynos/shared/providers/health_providers.dart';
import 'package:kynos/shared/utils/date_label.dart';
import 'package:kynos/shared/widgets/kynos_hero_banner.dart';
import 'package:kynos/shared/widgets/kynos_privacy_footer.dart';
import 'package:kynos/shared/widgets/kynos_section_header.dart';

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(healthSummaryProvider);
    final todayInsightsState = ref.watch(todayInsightsStateProvider);
    final showConnectCard =
        !kIsWeb && summary.value == null && !summary.isLoading;

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
              KynosHeroBanner(
                accentColor: AppTheme.stand,
                subtitle: _greeting(),
                title: 'KYNOS',
                caption: 'Your AI running coach',
              ),
              const Gap(tokens.Spacing.lg),
              ReadinessCard(
                summary: summary.value,
                todayInsightsState: todayInsightsState,
              ),
              const Gap(tokens.Spacing.md),
              TodayInsightCards(todayInsightsState: todayInsightsState),
              const Gap(tokens.Spacing.lg),
              const KynosSectionHeader(title: "Today's Metrics"),
              const Gap(tokens.Spacing.sm),
              HealthMetricsGrid(summary: summary.value),
              const Gap(tokens.Spacing.lg),
              if (showConnectCard) const ConnectHealthkitCard(),
              if (showConnectCard) const Gap(tokens.Spacing.lg),
              const KynosPrivacyFooter(),
            ],
          ),
        ),
      ],
    );
  }
}
