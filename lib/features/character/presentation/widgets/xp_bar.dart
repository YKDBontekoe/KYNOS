import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:kynos/core/theme/spacing.dart' as tokens;
import 'package:kynos/core/theme/theme.dart';
import 'package:kynos/domain/entities/gamification/runner_character.dart';
import 'package:kynos/shared/widgets/kynos_card.dart';

class XpBar extends StatelessWidget {
  const XpBar({super.key, required this.character});

  final RunnerCharacter character;

  @override
  Widget build(BuildContext context) {
    final kynos = context.kynosTheme;
    final classColor = Color(character.characterClass.colorValue);
    final progress = character.levelProgress;
    final earnedTowardNext =
        (character.xpForNextLevel - character.xpToNextLevel)
            .clamp(0, character.xpForNextLevel);

    return KynosCard(
      padding: const EdgeInsets.all(tokens.Spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'EXPERIENCE',
                style: Theme.of(context).textTheme.labelSmall,
              ),
              Text(
                'Level ${character.level}',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: kynos.secondaryLabel,
                    ),
              ),
            ],
          ),
          const Gap(tokens.Spacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(tokens.Radius.sm),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progress),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOut,
              builder: (context, value, _) {
                return LinearProgressIndicator(
                  value: value,
                  minHeight: 8,
                  backgroundColor: kynos.separator,
                  valueColor: AlwaysStoppedAnimation(classColor),
                );
              },
            ),
          ),
          const Gap(tokens.Spacing.xs),
          Text(
            '$earnedTowardNext / ${character.xpForNextLevel} XP toward '
            'Level ${character.level + 1}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: kynos.secondaryLabel,
                ),
          ),
        ],
      ),
    );
  }
}
