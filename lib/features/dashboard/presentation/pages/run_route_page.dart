import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:kynos/app/router.dart';
import 'package:kynos/core/theme/spacing.dart' as tokens;
import 'package:kynos/core/theme/theme.dart';
import 'package:kynos/domain/entities/workout_route_point.dart';
import 'package:kynos/domain/entities/workout_session.dart';
import 'package:kynos/domain/utils/run_route_analytics.dart';
import 'package:kynos/features/dashboard/presentation/widgets/run_detail/run_insight_chips.dart';
import 'package:kynos/features/dashboard/presentation/widgets/run_detail/run_pace_chart.dart';
import 'package:kynos/features/dashboard/presentation/widgets/run_detail/run_route_map_section.dart';
import 'package:kynos/features/dashboard/presentation/widgets/run_detail/run_split_list.dart';
import 'package:kynos/features/dashboard/presentation/widgets/run_detail/run_summary_metrics.dart';
import 'package:kynos/shared/constants/hero_tags.dart';
import 'package:kynos/shared/providers/health_providers.dart';
import 'package:kynos/shared/providers/workout_session_lookup_provider.dart';
import 'package:kynos/shared/utils/run_date_label.dart';
import 'package:kynos/shared/widgets/kynos_inline_error_card.dart';
import 'package:kynos/shared/widgets/kynos_privacy_footer.dart';
import 'package:kynos/shared/widgets/kynos_section_header.dart';
import 'package:kynos/shared/widgets/kynos_skeleton.dart';

class RunRoutePage extends ConsumerWidget {
  const RunRoutePage({super.key, this.run, this.runId})
      : assert(run != null || runId != null);

  final WorkoutSession? run;
  final String? runId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kynos = context.kynosTheme;
    final resolvedRun = run;
    if (resolvedRun != null) {
      return _RunRouteScaffold(run: resolvedRun);
    }

    final lookup = ref.watch(workoutSessionByIdProvider(runId!));
    return lookup.when(
      loading: () => Scaffold(
        backgroundColor: kynos.background,
        appBar: _runRouteAppBar(context),
        body: const Padding(
          padding: EdgeInsets.all(tokens.Spacing.md),
          child: KynosSkeleton.tile(height: 300),
        ),
      ),
      error: (_, _) => Scaffold(
        backgroundColor: kynos.background,
        appBar: _runRouteAppBar(context),
        body: Padding(
          padding: const EdgeInsets.all(tokens.Spacing.md),
          child: KynosInlineErrorCard(
            message: 'Could not load this run.',
            onRetry: () => ref.invalidate(workoutSessionByIdProvider(runId!)),
          ),
        ),
      ),
      data: (session) {
        if (session == null) {
          return Scaffold(
            backgroundColor: kynos.background,
            appBar: _runRouteAppBar(context),
            body: const Center(child: Text('Run not found on this device.')),
          );
        }
        return _RunRouteScaffold(run: session);
      },
    );
  }
}

AppBar _runRouteAppBar(BuildContext context, {WorkoutSession? run}) {
  final kynos = context.kynosTheme;
  return AppBar(
    title: run != null
        ? Hero(
            tag: RunHeroTags.date(run.id),
            child: Material(
              color: Colors.transparent,
              child: Text(formatRunHeroDateLabel(run.start)),
            ),
          )
        : const Text('Run Route'),
    backgroundColor: kynos.background,
    surfaceTintColor: Colors.transparent,
    leading: IconButton(
      icon: const Icon(Icons.arrow_back_rounded),
      onPressed: () {
        if (context.canPop()) {
          context.pop();
        } else {
          context.go(Routes.dashboard);
        }
      },
    ),
  );
}

class _RunRouteScaffold extends ConsumerWidget {
  const _RunRouteScaffold({required this.run});

  final WorkoutSession run;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kynos = context.kynosTheme;
    final routeAsync = ref.watch(runRouteProvider(workoutUuid: run.id));

    return Scaffold(
      backgroundColor: kynos.background,
      appBar: _runRouteAppBar(context, run: run),
      body: routeAsync.when(
        data: (points) => _RouteContent(run: run, points: points),
        loading: () => const Padding(
          padding: EdgeInsets.all(tokens.Spacing.md),
          child: KynosSkeleton.tile(height: 300),
        ),
        error: (_, _) => Padding(
          padding: const EdgeInsets.all(tokens.Spacing.md),
          child: KynosInlineErrorCard(
            message: 'Could not load the workout route. Try again in a moment.',
            onRetry: () => ref.invalidate(runRouteProvider(workoutUuid: run.id)),
          ),
        ),
      ),
    );
  }
}

class _RouteContent extends StatelessWidget {
  const _RouteContent({required this.run, required this.points});

  final WorkoutSession run;
  final List<WorkoutRoutePoint> points;

  @override
  Widget build(BuildContext context) {
    final analytics = computeRunRouteAnalytics(session: run, points: points);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: RunRouteMapSection(points: points)),
        SliverToBoxAdapter(child: RunRouteExternalMapsButton(points: points)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(bottom: tokens.Spacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                RunSummaryMetrics(run: run, analytics: analytics),
                const Gap(tokens.Spacing.lg),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: tokens.Spacing.md),
                  child: KynosSectionHeader(title: 'Pace Profile'),
                ),
                const Gap(tokens.Spacing.sm),
                RunPaceChart(analytics: analytics),
                const Gap(tokens.Spacing.lg),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: tokens.Spacing.md),
                  child: KynosSectionHeader(title: 'Kilometer Splits'),
                ),
                const Gap(tokens.Spacing.sm),
                RunSplitList(analytics: analytics),
                const Gap(tokens.Spacing.lg),
                RunInsightChips(
                  run: run,
                  analytics: analytics,
                  points: points,
                ),
                const Gap(tokens.Spacing.lg),
                const Center(child: KynosPrivacyFooter()),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
