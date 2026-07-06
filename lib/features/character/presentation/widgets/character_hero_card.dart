import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:kynos/core/theme/spacing.dart' as tokens;
import 'package:kynos/core/theme/theme.dart';
import 'package:kynos/domain/entities/gamification/runner_character.dart';
import 'package:kynos/shared/widgets/kynos_hero_banner.dart';

class CharacterHeroCard extends StatelessWidget {
  const CharacterHeroCard({
    super.key,
    required this.character,
    this.onAskCoach,
  });

  final RunnerCharacter character;
  final VoidCallback? onAskCoach;

  @override
  Widget build(BuildContext context) {
    final klass = character.characterClass;
    final classColor = Color(klass.colorValue);
    final kynos = context.kynosTheme;

    return KynosHeroBanner(
      accentColor: classColor,
      height: LayoutTokens.heroBannerHeightLarge,
      orbAlignment: Alignment.topRight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: KynosColors.onAccent.withValues(alpha: 0.20),
                  borderRadius: BorderRadius.circular(tokens.Radius.sm),
                ),
                child: Text(
                  'LV ${character.level}',
                  style: kynos.heroSubtitleStyle.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: KynosColors.onAccent,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const Gap(Spacing.sm),
              if (character.activeTitle != null)
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: KynosColors.onAccent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(tokens.Radius.sm),
                    ),
                    child: Text(
                      '"${character.activeTitle}"',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: kynos.heroSubtitleStyle.copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: KynosColors.onAccent.withValues(alpha: 0.90),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const Spacer(),
          Text(
            klass.name.toUpperCase(),
            style: kynos.heroTitleStyle.copyWith(fontSize: 28, letterSpacing: -0.5),
          ),
          const Gap(tokens.Spacing.xs),
          Text(
            klass.epithet,
            style: kynos.heroSubtitleStyle.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: KynosColors.onAccent.withValues(alpha: 0.75),
            ),
          ),
          if (onAskCoach != null) ...[
            const Gap(tokens.Spacing.sm),
            TextButton(
              onPressed: onAskCoach,
              style: TextButton.styleFrom(
                foregroundColor: KynosColors.onAccent,
              ),
              child: const Text('Ask Coach about my class'),
            ),
          ],
        ],
      ),
    );
  }
}
