import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:kynos/core/theme/theme.dart';
import 'package:kynos/domain/entities/gamification/quest.dart';
import 'package:kynos/shared/providers/daily_quests_provider.dart';
import 'package:kynos/shared/widgets/kynos_card.dart';
import 'package:kynos/shared/widgets/kynos_chip.dart';
import 'package:kynos/shared/widgets/kynos_inline_error_card.dart';
import 'package:kynos/shared/widgets/kynos_loading_line.dart';

/// Compact daily quest preview for the Today tab.
///
/// [onViewCharacter] is provided when this teaser is shown outside the
/// Character tab (e.g. on the dashboard) and links there. When `null`, the
/// widget assumes it is already displayed on the Character tab and instead
/// offers an in-place retry action for the empty state.
class DailyQuestTeaser extends ConsumerWidget {
  const DailyQuestTeaser({
    super.key,
    required this.questsAsync,
    this.onViewCharacter,
  });

  final AsyncValue<List<Quest>> questsAsync;
  final VoidCallback? onViewCharacter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kynos = context.kynosTheme;
    final isOnCharacterTab = onViewCharacter == null;

    return questsAsync.when(
      loading: () => const KynosCard(
        child: KynosLoadingLine(label: 'Loading daily quest...'),
      ),
      error: (_, _) => KynosInlineErrorCard(
        message: 'Could not load daily quest.',
        onRetry: () => ref.invalidate(dailyQuestsProvider),
      ),
      data: (quests) {
        if (quests.isEmpty) {
          return KynosCard(
            padding: const EdgeInsets.all(Spacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'No daily quest yet.',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Gap(Spacing.xs),
                Text(
                  isOnCharacterTab
                      ? 'Log a run or check in on your recovery to unlock '
                            'today\'s camp quest.'
                      : 'Open Character to generate today\'s camp quests.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: kynos.secondaryLabel,
                      ),
                ),
                const Gap(Spacing.sm),
                TextButton(
                  onPressed: onViewCharacter ??
                      () => ref.invalidate(dailyQuestsProvider),
                  child: Text(isOnCharacterTab ? 'Refresh' : 'View Character'),
                ),
              ],
            ),
          );
        }

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
                    'CAMP QUEST',
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
                      decoration:
                          isCompleted ? TextDecoration.lineThrough : null,
                      color: isCompleted ? kynos.secondaryLabel : kynos.label,
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
                        minimumSize: const Size(48, 48),
                        tapTargetSize: MaterialTapTargetSize.padded,
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
