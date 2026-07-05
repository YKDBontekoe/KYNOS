import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kynos/core/theme/spacing.dart' as tokens;
import 'package:kynos/core/theme/theme.dart';
import 'package:kynos/domain/entities/gamification/encounter_state.dart';
import 'package:kynos/shared/widgets/kynos_card.dart';

class EncounterPanel extends StatelessWidget {
  const EncounterPanel({
    super.key,
    required this.encounter,
    required this.availableStamina,
    required this.onAction,
    required this.onRetreat,
  });

  final EncounterState encounter;
  final int availableStamina;
  final void Function(CombatAction action) onAction;
  final VoidCallback onRetreat;

  @override
  Widget build(BuildContext context) {
    final hpFraction = encounter.enemyMaxHp > 0
        ? encounter.enemyHp / encounter.enemyMaxHp
        : 0.0;

    return KynosCard(
      padding: const EdgeInsets.all(tokens.Spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                encounter.isBoss ? 'BOSS FIGHT' : 'ENCOUNTER',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.tertiaryLabel,
                  letterSpacing: 0.8,
                ),
              ),
              const Spacer(),
              TextButton(onPressed: onRetreat, child: const Text('Retreat')),
            ],
          ),
          const Gap(tokens.Spacing.sm),
          Text(
            encounter.enemyId.replaceAll('_', ' ').toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppTheme.label,
            ),
          ),
          const Gap(tokens.Spacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(Radius.sm),
            child: LinearProgressIndicator(
              value: hpFraction.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: AppTheme.separator,
              color: AppTheme.energy,
            ),
          ),
          const Gap(tokens.Spacing.xs),
          Text(
            '${encounter.enemyHp} / ${encounter.enemyMaxHp} HP',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppTheme.secondaryLabel,
            ),
          ),
          if (encounter.combatLog.isNotEmpty) ...[
            const Gap(tokens.Spacing.sm),
            ...encounter.combatLog.map(
              (line) => Padding(
                padding: const EdgeInsets.only(bottom: tokens.Spacing.xs),
                child: Text(
                  line,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppTheme.secondaryLabel,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
          ],
          const Gap(tokens.Spacing.md),
          Wrap(
            spacing: tokens.Spacing.xs,
            runSpacing: tokens.Spacing.xs,
            children: CombatAction.values.map((action) {
              final cost = _staminaCost(action);
              final canAfford = availableStamina >= cost ||
                  (encounter.firstActionFree && action != CombatAction.recover);
              return FilledButton.tonal(
                onPressed: canAfford ? () => onAction(action) : null,
                child: Text('${action.label} ($cost)'),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  int _staminaCost(CombatAction action) => switch (action) {
        CombatAction.strike => 4,
        CombatAction.rush => 6,
        CombatAction.brace => 3,
        CombatAction.focus => 2,
        CombatAction.recover => 5,
      };
}
