import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:kynos/core/theme/spacing.dart' as tokens;
import 'package:kynos/core/theme/theme.dart';
import 'package:kynos/domain/entities/gamification/character_stats.dart';
import 'package:kynos/domain/entities/gamification/runner_character.dart';
import 'package:kynos/shared/widgets/kynos_card.dart';

class StatsPanel extends StatelessWidget {
  const StatsPanel({super.key, required this.character});

  final RunnerCharacter character;

  @override
  Widget build(BuildContext context) {
    return KynosCard(
      padding: const EdgeInsets.all(tokens.Spacing.md),
      child: Column(
        children: [
          for (final stat in CharacterStatId.values) ...[
            StatRow(
              stat: stat,
              value: character.stats[stat],
            ),
            if (stat != CharacterStatId.values.last)
              const Gap(tokens.Spacing.sm),
          ],
        ],
      ),
    );
  }
}

class StatRow extends StatelessWidget {
  const StatRow({super.key, required this.stat, required this.value});

  final CharacterStatId stat;
  final int value;

  @override
  Widget build(BuildContext context) {
    final kynos = context.kynosTheme;
    final statColor = kynos.accentForKey(stat.colorKey);
    final pct = value / 100.0;

    return Tooltip(
      message: '${stat.fullName} — ${stat.description}',
      waitDuration: const Duration(milliseconds: 300),
      child: Semantics(
        label: '${stat.fullName}: $value. ${stat.description}',
        child: Row(
          children: [
            SizedBox(
              width: 40,
              child: Text(
                stat.label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: statColor,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                    ),
              ),
            ),
            const Gap(tokens.Spacing.sm),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(tokens.Radius.sm),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: pct),
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.easeOut,
                  builder: (context, val, _) {
                    return LinearProgressIndicator(
                      value: val,
                      minHeight: 6,
                      backgroundColor: kynos.separator,
                      valueColor: AlwaysStoppedAnimation(statColor),
                    );
                  },
                ),
              ),
            ),
            const Gap(tokens.Spacing.sm),
            SizedBox(
              width: 30,
              child: Text(
                value.toString(),
                textAlign: TextAlign.right,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: kynos.label,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
