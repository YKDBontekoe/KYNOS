import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:kynos/core/theme/spacing.dart' as tokens;
import 'package:kynos/core/theme/theme.dart';
import 'package:kynos/domain/entities/gamification/camp_resources.dart';
import 'package:kynos/domain/entities/gamification/camp_state.dart';
import 'package:kynos/domain/entities/gamification/runner_character.dart';
import 'package:kynos/shared/widgets/animated_async_content.dart';
import 'package:kynos/shared/widgets/animated_progress_bar.dart';
import 'package:kynos/shared/widgets/kynos_card.dart';
import 'package:kynos/shared/widgets/kynos_chip.dart';

/// Compact character + camp progress card for the Today tab.
class CharacterGlanceCard extends StatelessWidget {
  const CharacterGlanceCard({
    super.key,
    required this.character,
    this.camp,
    this.resources,
    this.onViewCharacter,
  });

  final RunnerCharacter character;
  final CampState? camp;
  final CampResources? resources;
  final VoidCallback? onViewCharacter;

  @override
  Widget build(BuildContext context) {
    final kynos = context.kynosTheme;
    final classColor = Color(character.characterClass.colorValue);
    final semanticsLabel = onViewCharacter != null
        ? 'Character level ${character.level}, tap to view camp'
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
              if (camp != null) ...[
                const Gap(tokens.Spacing.sm),
                Text(
                  'SUMMIT ${camp!.weeklyAltitude}/${camp!.weeklyGoal} m',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                const Gap(tokens.Spacing.xs),
                AnimatedProgressBar(
                  value: camp!.summitProgress,
                  minHeight: 6,
                  backgroundColor: kynos.separator,
                  valueColor: kynos.move,
                  borderRadius: 3,
                ),
              ],
              if (resources != null) ...[
                const Gap(tokens.Spacing.sm),
                Text(
                  'Top resource: ${_topResource(resources!)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: kynos.secondaryLabel,
                      ),
                ),
              ],
              const Gap(tokens.Spacing.xs),
              Text(
                '${character.xpToNextLevel} XP to Level ${character.level + 1}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: kynos.tertiaryLabel,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _topResource(CampResources resources) {
    final entries = [
      ('Momentum', resources.availableMomentum),
      ('Fuel', resources.availableFuel),
      ('Focus', resources.availableFocus),
      ('Spirit', resources.availableSpirit),
    ]..sort((a, b) => b.$2.compareTo(a.$2));
    final top = entries.first;
    return '${top.$1} ${top.$2}';
  }
}
