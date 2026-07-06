import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:kynos/core/theme/spacing.dart' as tokens;
import 'package:kynos/core/theme/theme.dart';
import 'package:kynos/domain/entities/gamification/runner_character.dart';
import 'package:kynos/shared/widgets/animated_async_content.dart';
import 'package:kynos/shared/widgets/animated_progress_bar.dart';
import 'package:kynos/shared/widgets/kynos_card.dart';
import 'package:kynos/shared/widgets/kynos_chip.dart';

/// Compact character progress card for the Today tab.
class CharacterGlanceCard extends StatelessWidget {
  const CharacterGlanceCard({
    super.key,
    required this.character,
    this.onViewCharacter,
  });

  final RunnerCharacter character;
  final VoidCallback? onViewCharacter;

  @override
  Widget build(BuildContext context) {
    final kynos = context.kynosTheme;
    final classColor = Color(character.characterClass.colorValue);
    final weakest = character.stats.weakest;
    final semanticsLabel = onViewCharacter != null
        ? 'Character level ${character.level}, tap to view'
        : 'Character level ${character.level}';

    return FadeInOnAppear(
      child: Semantics(
        label: semanticsLabel,
        button: onViewCharacter != null,
        excludeSemantics: true,
        child: KynosCard(
        padding: const EdgeInsets.all(tokens.Spacing.md),
        onTap: onViewCharacter,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'LEVEL ${character.level}',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                const Spacer(),
                KynosChip.accent(
                  label: character.characterClass.name.replaceFirst('The ', ''),
                  color: classColor,
                ),
              ],
            ),
            const Gap(tokens.Spacing.sm),
            AnimatedProgressBar(
              value: character.levelProgress,
              minHeight: 8,
              backgroundColor: kynos.separator,
              valueColor: classColor,
              borderRadius: 4,
            ),
            const Gap(tokens.Spacing.xs),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${character.xpToNextLevel} XP to Level ${character.level + 1}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: kynos.tertiaryLabel,
                        ),
                  ),
                ),
                Text(
                  'Train ${weakest.fullName}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: kynos.purple,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
      ),
    );
  }
}
