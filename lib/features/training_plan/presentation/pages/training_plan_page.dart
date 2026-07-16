import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:kynos/app/router.dart';
import 'package:kynos/core/theme/spacing.dart' as tokens;
import 'package:kynos/core/theme/theme.dart';
import 'package:kynos/domain/entities/coach/coach_seed_topic.dart';
import 'package:kynos/domain/entities/coach/training_plan.dart';
import 'package:kynos/features/coach_chat/presentation/widgets/pending_coach_action_card.dart';
import 'package:kynos/features/training_plan/presentation/widgets/plan_week_calendar.dart';
import 'package:kynos/shared/providers/training_plan_providers.dart';
import 'package:kynos/shared/providers/weekly_adaptation_provider.dart';
import 'package:kynos/shared/utils/navigation_utils.dart';
import 'package:kynos/shared/utils/open_coach_chat.dart';
import 'package:kynos/shared/widgets/kynos_card.dart';
import 'package:kynos/shared/widgets/kynos_empty_cta.dart';
import 'package:kynos/shared/widgets/kynos_inline_error_card.dart';
import 'package:kynos/shared/widgets/kynos_skeleton.dart';

/// Coach-native week surface for the active [TrainingPlan].
class TrainingPlanPage extends ConsumerWidget {
  const TrainingPlanPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kynos = context.kynosTheme;
    final planAsync = ref.watch(trainingPlanDataProvider);
    final adaptation = ref.watch(weeklyAdaptationProvider);

    return Scaffold(
      backgroundColor: kynos.background,
      body: planAsync.when(
        loading: () => const _PlanLoadingScaffold(),
        error: (error, _) => Scaffold(
          backgroundColor: kynos.background,
          appBar: _appBar(context, kynos),
          body: Padding(
            padding: const EdgeInsets.all(tokens.Spacing.md),
            child: KynosInlineErrorCard(
              message: 'Could not load your training plan.',
              onRetry: () => ref.invalidate(trainingPlanDataProvider),
            ),
          ),
        ),
        data: (plan) {
          if (plan == null) {
            return Scaffold(
              backgroundColor: kynos.background,
              appBar: _appBar(context, kynos),
              body: Padding(
                padding: const EdgeInsets.all(tokens.Spacing.md),
                child: KynosCard(
                  child: KynosEmptyCta(
                    message:
                        'No active plan yet. Ask the coach to build a '
                        'multi-week plan from your goals.',
                    primaryLabel: 'Build my plan',
                    onPrimary: () => openCoachChat(
                      context,
                      ref,
                      seed:
                          'Build my multi-week training plan based on my goals.',
                      topic: CoachSeedTopic.training,
                    ),
                    icon: Icons.calendar_month_rounded,
                  ),
                ),
              ),
            );
          }

          return Scaffold(
            backgroundColor: kynos.background,
            body: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverAppBar(
                  backgroundColor: kynos.background,
                  surfaceTintColor: Colors.transparent,
                  elevation: 0,
                  pinned: true,
                  titleSpacing: 0,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back_rounded),
                    onPressed: () => popOrGo(context, Routes.dashboard),
                  ),
                  title: Text(
                    'Training plan',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => openCoachChat(
                        context,
                        ref,
                        seed:
                            'Review this week on my plan and adjust if needed '
                            'with adjust_plan_week.',
                        topic: CoachSeedTopic.weeklyGoal,
                      ),
                      child: const Text('Ask coach'),
                    ),
                  ],
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    tokens.Spacing.md,
                    tokens.Spacing.sm,
                    tokens.Spacing.md,
                    tokens.Spacing.xl,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      Text(
                        plan.title,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const Gap(tokens.Spacing.xs),
                      Text(
                        plan.goal,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: kynos.secondaryLabel,
                            ),
                      ),
                      const Gap(tokens.Spacing.lg),
                      PlanWeekCalendar(
                        plan: plan,
                        referenceDate: DateTime.now(),
                        onDayTap: (date, day) => _onDayTap(
                          context,
                          ref,
                          date: date,
                          day: day,
                        ),
                      ),
                      if (adaptation != null) ...[
                        const Gap(tokens.Spacing.lg),
                        PendingCoachActionCard(action: adaptation),
                        const Gap(tokens.Spacing.sm),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => ref
                                .read(weeklyAdaptationProvider.notifier)
                                .dismiss(),
                            child: const Text('Not now'),
                          ),
                        ),
                      ],
                      const Gap(tokens.Spacing.lg),
                      OutlinedButton.icon(
                        onPressed: () => context.push(Routes.runHistory),
                        icon: const Icon(Icons.history_rounded),
                        label: const Text('Run history'),
                      ),
                    ]),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _appBar(BuildContext context, KynosThemeExtension kynos) {
    return AppBar(
      backgroundColor: kynos.background,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        onPressed: () => popOrGo(context, Routes.dashboard),
      ),
      title: Text(
        'Training plan',
        style: Theme.of(context).textTheme.titleLarge,
      ),
    );
  }

  void _onDayTap(
    BuildContext context,
    WidgetRef ref, {
    required DateTime date,
    required PlanDay? day,
  }) {
    final label = day == null
        ? 'No session on ${_short(date)}'
        : '${day.title} on ${_short(date)} (${day.adherence.name})';
    openCoachChat(
      context,
      ref,
      seed: '$label. Explain why and adjust with adjust_plan_week if needed.',
      topic: CoachSeedTopic.training,
    );
  }

  String _short(DateTime date) => '${date.month}/${date.day}';
}

class _PlanLoadingScaffold extends StatelessWidget {
  const _PlanLoadingScaffold();

  @override
  Widget build(BuildContext context) {
    final kynos = context.kynosTheme;
    return Scaffold(
      backgroundColor: kynos.background,
      appBar: AppBar(
        backgroundColor: kynos.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Training plan',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body: const Padding(
        padding: EdgeInsets.all(tokens.Spacing.md),
        child: Column(
          children: [
            KynosSkeleton.tile(height: 72),
            Gap(tokens.Spacing.md),
            KynosSkeleton.tile(height: 148),
            Gap(tokens.Spacing.sm),
            KynosSkeleton.tile(height: 148),
          ],
        ),
      ),
    );
  }
}
