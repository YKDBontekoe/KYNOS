import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:kynos/app/router.dart';
import 'package:kynos/core/theme/spacing.dart' as tokens;
import 'package:kynos/core/theme/theme.dart';
import 'package:kynos/domain/entities/coach/coach_seed_topic.dart';
import 'package:kynos/features/character/presentation/widgets/camp_game_panel.dart';
import 'package:kynos/features/character/presentation/widgets/character_hero_card.dart';
import 'package:kynos/features/character/presentation/widgets/gamekit_panel.dart';
import 'package:kynos/features/character/presentation/widgets/quest_card.dart';
import 'package:kynos/features/character/presentation/widgets/signatory_power_card.dart';
import 'package:kynos/features/character/presentation/widgets/stats_panel.dart';
import 'package:kynos/features/character/presentation/widgets/summit_progress_card.dart';
import 'package:kynos/features/character/presentation/widgets/titles_panel.dart';
import 'package:kynos/features/character/presentation/widgets/wellbeing_quest_panel.dart';
import 'package:kynos/features/character/presentation/widgets/xp_bar.dart';
import 'package:kynos/shared/providers/camp_providers.dart';
import 'package:kynos/shared/providers/character_providers.dart';
import 'package:kynos/shared/providers/daily_quests_provider.dart';
import 'package:kynos/shared/providers/health_coach_providers.dart';
import 'package:kynos/shared/providers/health_providers.dart';
import 'package:kynos/shared/providers/nexus_lab_provider.dart';
import 'package:kynos/shared/utils/health_permission_feedback.dart';
import 'package:kynos/shared/utils/health_platform_labels.dart';
import 'package:kynos/shared/utils/open_coach_chat.dart';
import 'package:kynos/shared/widgets/daily_quest_teaser.dart';
import 'package:kynos/shared/widgets/kynos_inline_error_card.dart';
import 'package:kynos/shared/widgets/kynos_section_header.dart';
import 'package:kynos/shared/widgets/kynos_skeleton.dart';

class CharacterPage extends ConsumerWidget {
  const CharacterPage({super.key});

  Future<void> _refreshCharacter(WidgetRef ref) async {
    ref.invalidate(runnerCharacterProvider);
    ref.invalidate(dailyQuestsProvider);
    ref.invalidate(campSessionProvider);
    ref.invalidate(nexusLabProvider);
    ref.invalidate(healthCoachDataProvider);
    await Future.wait([
      ref.read(runnerCharacterProvider.future),
      ref.read(dailyQuestsProvider.future),
      ref.read(campSessionProvider.future),
      ref.read(nexusLabProvider.future),
      ref.read(healthCoachDataProvider.future),
    ]);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kynos = context.kynosTheme;
    final characterAsync = ref.watch(runnerCharacterProvider);
    final questsAsync = ref.watch(dailyQuestsProvider);
    final campAsync = ref.watch(campSessionProvider);
    final wellbeingState = ref.watch(healthCoachDataProvider);

    return RefreshIndicator(
      onRefresh: () => _refreshCharacter(ref),
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
              'JOURNEY',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: kynos.tertiaryLabel,
                letterSpacing: 0.8,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          characterAsync.when(
            loading: () => const SliverFillRemaining(
              child: Padding(
                padding: EdgeInsets.all(tokens.Spacing.md),
                child: Column(
                  children: [
                    KynosSkeleton.tile(height: 160),
                    Gap(tokens.Spacing.md),
                    KynosSkeleton.tile(height: 48),
                    Gap(tokens.Spacing.lg),
                    KynosSkeleton.tile(height: 200),
                  ],
                ),
              ),
            ),
            error: (_, _) => SliverFillRemaining(
              child: Padding(
                padding: const EdgeInsets.all(tokens.Spacing.md),
                child: KynosInlineErrorCard(
                  message: 'Could not load character.',
                  onRetry: () => ref.invalidate(runnerCharacterProvider),
                ),
              ),
            ),
            data: (character) {
              if (character == null) {
                return const SliverFillRemaining(child: EmptyCharacterState());
              }
              return SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  tokens.Spacing.md,
                  0,
                  tokens.Spacing.md,
                  LayoutTokens.shellBottomPadding(context),
                ),
                sliver: SliverList.list(
                  children: [
                    const KynosSectionHeader(title: 'YOUR WELLBEING JOURNEY'),
                    const Gap(tokens.Spacing.sm),
                    wellbeingState.when(
                      loading: () => const KynosSkeleton.tile(height: 96),
                      error: (_, _) => KynosInlineErrorCard(
                        message: 'Could not load wellbeing quests.',
                        onRetry: () => ref.invalidate(healthCoachDataProvider),
                      ),
                      data: (data) =>
                          WellbeingQuestPanel(experiments: data.experiments),
                    ),
                    const Gap(tokens.Spacing.lg),
                    campAsync.when(
                      loading: () => const KynosSkeleton.tile(height: 72),
                      error: (_, _) => KynosInlineErrorCard(
                        message: 'Could not load camp.',
                        onRetry: () => ref.invalidate(campSessionProvider),
                      ),
                      data: (viewState) {
                        if (viewState == null) return const SizedBox.shrink();
                        return Column(
                          children: [
                            SummitProgressCard(camp: viewState.camp),
                            const Gap(tokens.Spacing.md),
                            const KynosSectionHeader(title: 'SUMMIT CAMP'),
                            const Gap(tokens.Spacing.sm),
                            const CampGamePanel(),
                          ],
                        );
                      },
                    ),
                    const Gap(tokens.Spacing.lg),
                    CharacterHeroCard(
                      character: character,
                      onAskCoach: () => openCoachChat(
                        context,
                        ref,
                        seed:
                            'Why am I assigned as ${character.characterClass.name}? '
                            'What does this class mean for my training?',
                        topic: CoachSeedTopic.characterClass,
                      ),
                    ),
                    const Gap(tokens.Spacing.md),
                    XpBar(character: character),
                    const Gap(tokens.Spacing.lg),
                    const KynosSectionHeader(title: 'DAILY QUEST'),
                    const Gap(tokens.Spacing.sm),
                    DailyQuestTeaser(questsAsync: questsAsync),
                    const Gap(tokens.Spacing.lg),
                    const KynosSectionHeader(title: 'STATS'),
                    const Gap(tokens.Spacing.sm),
                    StatsPanel(character: character),
                    const Gap(tokens.Spacing.lg),
                    const KynosSectionHeader(title: "TODAY'S CAMP QUESTS"),
                    const Gap(tokens.Spacing.sm),
                    QuestPanel(
                      questsAsync: questsAsync,
                      onAskCoach: (quest) => openCoachChat(
                        context,
                        ref,
                        seed:
                            'How can I complete this quest: "${quest.objective}"?',
                        topic: CoachSeedTopic.quest,
                        questId: quest.id,
                      ),
                    ),
                    const Gap(tokens.Spacing.lg),
                    if (character.earnedTitles.isNotEmpty) ...[
                      const KynosSectionHeader(title: 'TITLES'),
                      const Gap(tokens.Spacing.sm),
                      TitlesPanel(titles: character.earnedTitles),
                      const Gap(tokens.Spacing.lg),
                    ],
                    const GameKitPanel(),
                    const Gap(tokens.Spacing.lg),
                    SignatoryPowerCard(
                      characterClass: character.characterClass,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class EmptyCharacterState extends ConsumerWidget {
  const EmptyCharacterState({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kynos = context.kynosTheme;
    final permissionState = ref.watch(healthPermissionsProvider);
    final isLoading = permissionState.isLoading;
    final platform = HealthPlatformLabels.platformName();
    return Padding(
      padding: const EdgeInsets.all(tokens.Spacing.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'JOURNEY NOT STARTED',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: kynos.tertiaryLabel,
              letterSpacing: 0.8,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Gap(tokens.Spacing.sm),
          Text(
            HealthPlatformLabels.characterEmptyHint(),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: kynos.secondaryLabel,
              height: 1.4,
            ),
          ),
          const Gap(tokens.Spacing.lg),
          if (!kIsWeb)
            FilledButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      await ref
                          .read(healthPermissionsProvider.notifier)
                          .request();

                      if (!context.mounted) return;

                      ref
                          .read(healthPermissionsProvider)
                          .whenOrNull(
                            data: (granted) {
                              final message = granted
                                  ? HealthPermissionFeedback.connectedMessage(
                                      platform,
                                    )
                                  : HealthPermissionFeedback.permissionDeniedMessage(
                                      platform,
                                    );
                              ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(SnackBar(content: Text(message)));
                            },
                            error: (_, _) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    HealthPermissionFeedback.connectionFailedMessage(),
                                  ),
                                ),
                              );
                            },
                          );
                    },
              child: Text(
                isLoading ? 'Connecting…' : HealthPlatformLabels.connectLabel(),
              ),
            ),
          const Gap(tokens.Spacing.sm),
          OutlinedButton(
            onPressed: () => context.push(Routes.healthImport),
            child: const Text('Import a run'),
          ),
          const Gap(tokens.Spacing.sm),
          OutlinedButton(
            onPressed: () => context.push(Routes.manualRun),
            child: const Text('Log a run manually'),
          ),
          const Gap(tokens.Spacing.sm),
          TextButton(
            onPressed: () => ref.invalidate(runnerCharacterProvider),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
}
