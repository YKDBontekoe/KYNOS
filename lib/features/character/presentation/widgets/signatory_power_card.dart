import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kynos/core/theme/spacing.dart' as tokens;
import 'package:kynos/domain/entities/gamification/character_class.dart';
import 'package:kynos/features/character/presentation/widgets/character_shield_icon.dart';
import 'package:kynos/shared/widgets/kynos_card.dart';

class SignatoryPowerCard extends StatelessWidget {
  const SignatoryPowerCard({super.key, required this.characterClass});

  final CharacterClass characterClass;

  @override
  Widget build(BuildContext context) {
    final classColor = Color(characterClass.colorValue);

    return KynosCard(
      padding: const EdgeInsets.all(tokens.Spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: classColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: CustomPaint(
                    size: const Size(18, 18),
                    painter: CharacterShieldPainter(color: classColor),
                  ),
                ),
              ),
              const Gap(tokens.Spacing.sm),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SIGNATORY POWER',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  Text(
                    characterClass.signatoryPower,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: classColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Gap(tokens.Spacing.sm),
          Text(
            characterClass.powerDescription,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
