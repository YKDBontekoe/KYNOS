import 'package:kynos/domain/entities/gamification/camp_building.dart';
import 'package:kynos/domain/entities/gamification/camp_state.dart';
import 'package:kynos/domain/entities/gamification/camp_tile.dart';

class BuildCampStructureResult {
  const BuildCampStructureResult({
    required this.camp,
    this.failure,
  });

  final CampState camp;
  final String? failure;

  bool get isSuccess => failure == null;
}

class BuildCampStructureUseCase {
  const BuildCampStructureUseCase();

  BuildCampStructureResult call({
    required CampState camp,
    required int row,
    required int col,
    required CampBuildingType type,
    required int availableFuel,
  }) {
    if (row < 0 || col < 0 || row >= camp.gridSize || col >= camp.gridSize) {
      return BuildCampStructureResult(
        camp: camp,
        failure: 'Tile out of bounds.',
      );
    }

    final tile = camp.tileAt(row, col);
    if (tile == null || tile.status == CampTileStatus.locked) {
      return BuildCampStructureResult(
        camp: camp,
        failure: 'Unlock this tile first.',
      );
    }

    final existing = camp.buildingAt(row, col);
    final fuelCost = existing == null
        ? type.baseFuelCost
        : type.upgradeFuelCost(existing.level);

    if (availableFuel < fuelCost) {
      return BuildCampStructureResult(
        camp: camp,
        failure: 'Not enough Fuel.',
      );
    }

    final List<PlacedBuilding> updatedBuildings;
    final int summitGain;

    if (existing == null) {
      updatedBuildings = [
        ...camp.buildings,
        PlacedBuilding(type: type, level: 1, row: row, col: col),
      ];
      summitGain = type.summitContribution(1);
    } else if (existing.type == type && existing.level < 3) {
      updatedBuildings = camp.buildings.map((b) {
        if (b.row == row && b.col == col) {
          return b.copyWith(level: b.level + 1);
        }
        return b;
      }).toList();
      summitGain = type.summitContribution(existing.level + 1);
    } else {
      return BuildCampStructureResult(
        camp: camp,
        failure: existing.type == type
            ? 'Building is max level.'
            : 'Tile already has a building.',
      );
    }

    final updatedTiles = camp.tiles.map((t) {
      if (t.row == row && t.col == col) {
        return t.copyWith(status: CampTileStatus.built);
      }
      return t;
    }).toList();

    return BuildCampStructureResult(
      camp: camp.copyWith(
        tiles: updatedTiles,
        buildings: updatedBuildings,
        spentFuel: camp.spentFuel + fuelCost,
        weeklyAltitude: camp.weeklyAltitude + summitGain,
      ),
    );
  }
}
