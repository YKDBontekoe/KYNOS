import 'package:flutter/material.dart';
import 'package:kynos/core/theme/spacing.dart' as tokens;
import 'package:kynos/core/theme/theme.dart';
import 'package:kynos/domain/entities/gamification/camp_building.dart';
import 'package:kynos/domain/entities/gamification/camp_state.dart';
import 'package:kynos/domain/entities/gamification/camp_tile.dart';

class CampGrid extends StatelessWidget {
  const CampGrid({
    super.key,
    required this.camp,
    required this.onTileTap,
    this.selectedRow,
    this.selectedCol,
  });

  final CampState camp;
  final void Function(int row, int col) onTileTap;
  final int? selectedRow;
  final int? selectedCol;

  @override
  Widget build(BuildContext context) {
    final kynos = context.kynosTheme;

    return AspectRatio(
      aspectRatio: 1,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: camp.gridSize,
          crossAxisSpacing: tokens.Spacing.xs,
          mainAxisSpacing: tokens.Spacing.xs,
        ),
        itemCount: camp.gridSize * camp.gridSize,
        itemBuilder: (context, index) {
          final row = index ~/ camp.gridSize;
          final col = index % camp.gridSize;
          final tile = camp.tileAt(row, col)!;
          final building = camp.buildingAt(row, col);
          final isSelected = row == selectedRow && col == selectedCol;

          return _CampTileCell(
            tile: tile,
            building: building,
            isSelected: isSelected,
            kynos: kynos,
            onTap: () => onTileTap(row, col),
          );
        },
      ),
    );
  }
}

class _CampTileCell extends StatelessWidget {
  const _CampTileCell({
    required this.tile,
    required this.building,
    required this.isSelected,
    required this.kynos,
    required this.onTap,
  });

  final CampTile tile;
  final PlacedBuilding? building;
  final bool isSelected;
  final KynosThemeExtension kynos;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isLocked = tile.isLocked;
    final color = switch (tile.status) {
      CampTileStatus.locked => kynos.separator,
      CampTileStatus.unlocked => kynos.card,
      CampTileStatus.built => kynos.move.withValues(alpha: 0.15),
    };

    return Tooltip(
      message: isLocked
          ? 'Locked — spend Momentum to expand this tile'
          : building != null
              ? building!.type.label
              : 'Empty plot — tap to build',
      waitDuration: const Duration(milliseconds: 400),
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(tokens.Spacing.xs),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(tokens.Spacing.xs),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(tokens.Spacing.xs),
              border: isSelected
                  ? Border.all(color: kynos.purple, width: 2)
                  : null,
            ),
            child: Center(
              child: isLocked
                  ? Icon(
                      Icons.lock_outline,
                      size: 14,
                      color: kynos.tertiaryLabel,
                    )
                  : building != null
                      ? Icon(
                          _buildingIcon(building!.type),
                          size: 18,
                          color: kynos.label,
                        )
                      : Icon(
                          Icons.terrain_outlined,
                          size: 16,
                          color: kynos.secondaryLabel,
                        ),
            ),
          ),
        ),
      ),
    );
  }

  IconData _buildingIcon(CampBuildingType type) => switch (type) {
        CampBuildingType.trackLoop => Icons.loop_rounded,
        CampBuildingType.recoveryYurt => Icons.night_shelter_outlined,
        CampBuildingType.paceTower => Icons.flag_outlined,
        CampBuildingType.summitBeacon => Icons.landscape_outlined,
      };
}
