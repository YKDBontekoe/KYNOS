import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kynos/core/theme/spacing.dart' as tokens;
import 'package:kynos/core/theme/theme.dart';
import 'package:kynos/domain/entities/gamification/runner_character.dart';
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

    return Semantics(
      label: 'Character level ${character.level}, tap to view',
      button: onViewCharacter != null,
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
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: character.levelProgress,
                minHeight: 8,
                backgroundColor: kynos.separator,
                valueColor: AlwaysStoppedAnimation(classColor),
              ),
            ),
            const Gap(tokens.Spacing.xs),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${character.xpToNextLevel} XP to Level ${character.level + 1}',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: kynos.tertiaryLabel,
                    ),
                  ),
                ),
                Text(
                  'Train ${weakest.fullName}',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: kynos.purple,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
