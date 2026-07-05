import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kynos/core/theme/spacing.dart' as tokens;
import 'package:kynos/core/theme/theme.dart';
import 'package:kynos/domain/entities/gamification/quest.dart';
import 'package:kynos/features/character/providers/quest_provider.dart';
import 'package:kynos/shared/widgets/kynos_card.dart';
import 'package:kynos/shared/widgets/kynos_chip.dart';
import 'package:kynos/shared/widgets/kynos_loading_line.dart';

class QuestPanel extends StatelessWidget {
  const QuestPanel({super.key, required this.questsAsync});

  final AsyncValue<List<Quest>> questsAsync;

  @override
  Widget build(BuildContext context) {
    return questsAsync.when(
      loading: () => const KynosCard(
        child: KynosLoadingLine(label: 'Generating quest...'),
      ),
      error: (_, _) => const SizedBox.shrink(),
      data: (quests) {
        if (quests.isEmpty) {
          return KynosCard(
            child: Text(
              'No quest today. Check back tomorrow.',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppTheme.secondaryLabel,
              ),
            ),
          );
        }
        return Column(
          children: [
            for (final quest in quests)
              QuestCard(quest: quest),
          ],
        );
      },
    );
  }
}

class QuestCard extends ConsumerWidget {
  const QuestCard({super.key, required this.quest});

  final Quest quest;

  Color _difficultyColor(QuestDifficulty d) => switch (d) {
        QuestDifficulty.easy => AppTheme.exercise,
        QuestDifficulty.normal => AppTheme.stand,
        QuestDifficulty.hard => AppTheme.energy,
        QuestDifficulty.legendary => AppTheme.move,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kynos = context.kynosTheme;
    final isCompleted = quest.status == QuestStatus.completed;
    final diffColor = _difficultyColor(quest.difficulty);

    return KynosCard(
      padding: const EdgeInsets.all(tokens.Spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: diffColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  quest.type.label,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: diffColor,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
              const Gap(tokens.Spacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.separator,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  quest.difficulty.label,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.secondaryLabel,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
              const Spacer(),
              if (isCompleted)
                const Icon(
                  Icons.check_circle_rounded,
                  size: 18,
                  color: AppTheme.exercise,
                ),
            ],
          ),
          const Gap(tokens.Spacing.sm),
          Text(
            quest.title.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: isCompleted ? AppTheme.secondaryLabel : AppTheme.label,
              letterSpacing: -0.2,
            ),
          ),
          const Gap(tokens.Spacing.xs),
          Text(
            '"${quest.narrative}"',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: AppTheme.secondaryLabel,
              fontStyle: FontStyle.italic,
              height: 1.4,
            ),
          ),
          const Gap(tokens.Spacing.sm),
          const Divider(height: 1),
          const Gap(tokens.Spacing.sm),
          Text(
            quest.objective,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppTheme.label,
              height: 1.4,
            ),
          ),
          const Gap(tokens.Spacing.sm),
          Wrap(
            spacing: Spacing.xs,
            runSpacing: Spacing.xs,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              KynosChip.accent(
                label: '+${quest.xpReward} XP',
                color: kynos.purple,
              ),
              for (final entry in quest.statRewards.entries)
                KynosChip.accent(
                  label: '+${entry.value} ${entry.key.label}',
                  color: kynos.accentForKey(entry.key.colorKey),
                ),
              if (!isCompleted)
                FilledButton(
                  onPressed: () => ref
                      .read(questProvider.notifier)
                      .completeQuest(quest.id),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(0, 32),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 7,
                    ),
                  ),
                  child: const Text('Complete'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
