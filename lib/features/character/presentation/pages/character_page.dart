import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kynos/core/theme/spacing.dart' as tokens;
import 'package:kynos/core/theme/theme.dart';
import 'package:kynos/features/character/presentation/widgets/character_hero_card.dart';
import 'package:kynos/features/character/presentation/widgets/gamekit_panel.dart';
import 'package:kynos/features/character/presentation/widgets/quest_card.dart';
import 'package:kynos/features/character/presentation/widgets/signatory_power_card.dart';
import 'package:kynos/features/character/presentation/widgets/stats_panel.dart';
import 'package:kynos/features/character/presentation/widgets/titles_panel.dart';
import 'package:kynos/features/character/presentation/widgets/trail_run_game_panel.dart';
import 'package:kynos/features/character/presentation/widgets/xp_bar.dart';
import 'package:kynos/features/character/providers/character_provider.dart';
import 'package:kynos/shared/providers/daily_quests_provider.dart';
import 'package:kynos/shared/widgets/kynos_section_header.dart';
import 'package:kynos/shared/widgets/kynos_skeleton.dart';

class CharacterPage extends ConsumerWidget {
  const CharacterPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final characterAsync = ref.watch(runnerCharacterProvider);
    final questsAsync = ref.watch(dailyQuestsProvider);

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
            'CHARACTER',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.tertiaryLabel,
              letterSpacing: 0.8,
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
            child: Center(
              child: Text(
                'Could not load character',
                style: GoogleFonts.inter(color: AppTheme.secondaryLabel),
              ),
            ),
          ),
          data: (character) {
            if (character == null) {
              return const SliverFillRemaining(
                child: EmptyCharacterState(),
              );
            }
            return SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                tokens.Spacing.md,
                0,
                tokens.Spacing.md,
                LayoutTokens.shellBottomPadding,
              ),
              sliver: SliverList.list(
                children: [
                  const TrailRunGamePanel(),
                  const Gap(tokens.Spacing.lg),
                  CharacterHeroCard(character: character),
                  const Gap(tokens.Spacing.md),
                  XpBar(character: character),
                  const Gap(tokens.Spacing.lg),
                  const KynosSectionHeader(title: 'STATS'),
                  const Gap(tokens.Spacing.sm),
                  StatsPanel(character: character),
                  const Gap(tokens.Spacing.lg),
                  const KynosSectionHeader(title: "TODAY'S QUEST"),
                  const Gap(tokens.Spacing.sm),
                  QuestPanel(questsAsync: questsAsync),
                  const Gap(tokens.Spacing.lg),
                  if (character.earnedTitles.isNotEmpty) ...[
                    const KynosSectionHeader(title: 'TITLES'),
                    const Gap(tokens.Spacing.sm),
                    TitlesPanel(titles: character.earnedTitles),
                    const Gap(tokens.Spacing.lg),
                  ],
                  const GameKitPanel(),
                  const Gap(tokens.Spacing.lg),
                  SignatoryPowerCard(characterClass: character.characterClass),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class EmptyCharacterState extends ConsumerWidget {
  const EmptyCharacterState({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(tokens.Spacing.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'CHARACTER NOT ASSIGNED',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.tertiaryLabel,
              letterSpacing: 0.8,
            ),
          ),
          const Gap(tokens.Spacing.sm),
          Text(
            'Connect HealthKit and log a few runs to unlock your class assignment.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppTheme.secondaryLabel,
              height: 1.4,
            ),
          ),
          const Gap(tokens.Spacing.lg),
          FilledButton(
            onPressed: () => ref.invalidate(runnerCharacterProvider),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
}
