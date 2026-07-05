import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kynos/core/theme/spacing.dart' as tokens;
import 'package:kynos/core/theme/theme.dart';
import 'package:kynos/domain/entities/gamification/runner_character.dart';
import 'package:kynos/shared/widgets/kynos_card.dart';

class XpBar extends StatelessWidget {
  const XpBar({super.key, required this.character});

  final RunnerCharacter character;

  @override
  Widget build(BuildContext context) {
    final classColor = Color(character.characterClass.colorValue);
    final progress = character.levelProgress;

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
                '${character.xpToNextLevel} XP to Level ${character.level + 1}',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: AppTheme.tertiaryLabel,
                ),
              ),
            ],
          ),
          const Gap(tokens.Spacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progress),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOut,
              builder: (context, value, _) {
                return LinearProgressIndicator(
                  value: value,
                  minHeight: 8,
                  backgroundColor: AppTheme.separator,
                  valueColor: AlwaysStoppedAnimation(classColor),
                );
              },
            ),
          ),
          const Gap(tokens.Spacing.xs),
          Text(
            '${character.xp} XP total',
            style: GoogleFonts.inter(
              fontSize: 11,
              color: AppTheme.tertiaryLabel,
            ),
          ),
        ],
      ),
    );
  }
}
