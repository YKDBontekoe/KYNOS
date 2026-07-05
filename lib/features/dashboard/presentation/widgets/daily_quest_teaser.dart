import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:kynos/core/theme/theme.dart';
import 'package:kynos/domain/entities/gamification/quest.dart';
import 'package:kynos/shared/widgets/kynos_card.dart';
import 'package:kynos/shared/widgets/kynos_chip.dart';
import 'package:kynos/shared/widgets/kynos_loading_line.dart';

/// Compact daily quest preview for the Today tab.
class DailyQuestTeaser extends StatelessWidget {
  const DailyQuestTeaser({
    super.key,
    required this.questsAsync,
    this.onViewCharacter,
  });

  final AsyncValue<List<Quest>> questsAsync;
  final VoidCallback? onViewCharacter;

  @override
  Widget build(BuildContext context) {
    final kynos = context.kynosTheme;

    return questsAsync.when(
      loading: () => const KynosCard(
        child: KynosLoadingLine(label: 'Loading daily quest...'),
      ),
      error: (_, _) => const SizedBox.shrink(),
      data: (quests) {
        if (quests.isEmpty) return const SizedBox.shrink();

        final quest = quests.first;
        final isCompleted = quest.status == QuestStatus.completed;

        return KynosCard(
          padding: const EdgeInsets.all(Spacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'DAILY QUEST',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  const Spacer(),
                  if (isCompleted)
                    Icon(
                      Icons.check_circle_rounded,
                      size: 16,
                      color: kynos.exercise,
                    ),
                ],
              ),
              const Gap(Spacing.xs),
              Text(
                quest.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      decoration: isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                      color: isCompleted
                          ? kynos.secondaryLabel
                          : kynos.label,
                    ),
              ),
              const Gap(Spacing.xs),
              Text(
                quest.objective,
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Gap(Spacing.sm),
              Row(
                children: [
                  KynosChip.accent(
                    label: '+${quest.xpReward} XP',
                    color: kynos.purple,
                  ),
                  const Spacer(),
                  if (onViewCharacter != null)
                    TextButton(
                      onPressed: onViewCharacter,
                      style: TextButton.styleFrom(
                        minimumSize: Size.zero,
                        padding: EdgeInsets.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text('View Character'),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
