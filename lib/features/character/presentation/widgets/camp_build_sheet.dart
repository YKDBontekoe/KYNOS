import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:kynos/core/constants/gamification_constants.dart';
import 'package:kynos/core/theme/spacing.dart' as tokens;
import 'package:kynos/core/theme/theme.dart';
import 'package:kynos/domain/entities/gamification/camp_building.dart';
import 'package:kynos/domain/entities/gamification/camp_state.dart';

class CampBuildSheet extends StatelessWidget {
  const CampBuildSheet({
    super.key,
    required this.camp,
    required this.row,
    required this.col,
    required this.availableFuel,
    required this.availableMomentum,
    required this.onBuild,
    required this.onExpand,
  });

  final CampState camp;
  final int row;
  final int col;
  final int availableFuel;
  final int availableMomentum;
  final void Function(CampBuildingType type) onBuild;
  final VoidCallback onExpand;

  static Future<void> show(
    BuildContext context, {
    required CampState camp,
    required int row,
    required int col,
    required int availableFuel,
    required int availableMomentum,
    required void Function(CampBuildingType type) onBuild,
    required VoidCallback onExpand,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => CampBuildSheet(
        camp: camp,
        row: row,
        col: col,
        availableFuel: availableFuel,
        availableMomentum: availableMomentum,
        onBuild: onBuild,
        onExpand: onExpand,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final kynos = context.kynosTheme;
    final tile = camp.tileAt(row, col);
    final building = camp.buildingAt(row, col);
    final canExpand = tile?.isLocked == true &&
        camp.isAdjacentToUnlocked(row, col) &&
        availableMomentum >= GamificationConstants.momentumPerTileExpand;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          tokens.Spacing.md,
          0,
          tokens.Spacing.md,
          tokens.Spacing.md,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'TILE ($row, $col)',
              style: Theme.of(context).textTheme.labelSmall,
            ),
            const Gap(tokens.Spacing.sm),
            if (canExpand) ...[
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onExpand,
                  icon: const Icon(Icons.explore_outlined),
                  label: const Text(
                    'Expand (${GamificationConstants.momentumPerTileExpand} Momentum)',
                  ),
                ),
              ),
              const Gap(tokens.Spacing.md),
            ],
            if (tile != null && !tile.isLocked) ...[
              Text(
                building == null ? 'BUILD' : 'UPGRADE',
                style: Theme.of(context).textTheme.labelSmall,
              ),
              const Gap(tokens.Spacing.sm),
              ...CampBuildingType.values.map((type) {
                final cost = building == null
                    ? type.baseFuelCost
                    : building.type == type
                        ? type.upgradeFuelCost(building.level)
                        : null;
                if (cost == null) return const SizedBox.shrink();
                final canAfford = availableFuel >= cost;
                return Padding(
                  padding: const EdgeInsets.only(bottom: tokens.Spacing.xs),
                  child: ListTile(
                    tileColor: kynos.card,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(tokens.Spacing.sm),
                    ),
                    title: Text(type.label),
                    subtitle: Text(type.description),
                    trailing: Text(
                      '$cost Fuel',
                      style: TextStyle(
                        color: canAfford ? kynos.energy : kynos.tertiaryLabel,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onTap: canAfford ? () => onBuild(type) : null,
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}
