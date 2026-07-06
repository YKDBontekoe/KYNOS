import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:kynos/core/constants/gamification_constants.dart';
import 'package:kynos/core/theme/spacing.dart' as tokens;
import 'package:kynos/core/theme/theme.dart';
import 'package:kynos/domain/entities/gamification/camp_resources.dart';
import 'package:kynos/domain/entities/gamification/expedition_event.dart';
import 'package:kynos/shared/widgets/kynos_card.dart';

class ExpeditionCard extends StatelessWidget {
  const ExpeditionCard({
    super.key,
    required this.resources,
    required this.expeditionUsedToday,
    required this.hasRunToday,
    required this.onLaunch,
    this.lastExpedition,
  });

  final CampResources resources;
  final bool expeditionUsedToday;
  final bool hasRunToday;
  final VoidCallback onLaunch;
  final ExpeditionEvent? lastExpedition;

  @override
  Widget build(BuildContext context) {
    final kynos = context.kynosTheme;
    final canLaunch = !expeditionUsedToday &&
        hasRunToday &&
        resources.canSpendSpirit(GamificationConstants.spiritCostExpedition);

    if (lastExpedition != null) {
      return KynosCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              lastExpedition!.title.toUpperCase(),
              style: Theme.of(context).textTheme.labelSmall,
            ),
            const Gap(tokens.Spacing.xs),
            Text(
              lastExpedition!.narrative,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const Gap(tokens.Spacing.sm),
            Text(
              '+${lastExpedition!.xpReward} XP',
              style: kynos.metricValueStyle.copyWith(color: kynos.purple),
            ),
          ],
        ),
      );
    }

    if (!hasRunToday) return const SizedBox.shrink();

    return KynosCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'RUN EXPEDITION',
            style: Theme.of(context).textTheme.labelSmall,
          ),
          const Gap(tokens.Spacing.xs),
          Text(
            expeditionUsedToday
                ? 'Expedition complete for today.'
                : 'Launch a scout mission from today\'s run.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: kynos.secondaryLabel,
                ),
          ),
          const Gap(tokens.Spacing.sm),
          FilledButton(
            onPressed: canLaunch ? onLaunch : null,
            child: Text(
              expeditionUsedToday
                  ? 'Done'
                  : 'Launch (${GamificationConstants.spiritCostExpedition} Spirit)',
            ),
          ),
        ],
      ),
    );
  }
}
