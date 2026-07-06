import 'package:kynos/core/constants/gamification_constants.dart';
import 'package:kynos/domain/entities/gamification/camp_state.dart';
import 'package:kynos/domain/entities/gamification/camp_tile.dart';

class ExpandCampTileResult {
  const ExpandCampTileResult({
    required this.camp,
    this.failure,
  });

  final CampState camp;
  final String? failure;

  bool get isSuccess => failure == null;
}

class ExpandCampTileUseCase {
  const ExpandCampTileUseCase();

  ExpandCampTileResult call({
    required CampState camp,
    required int row,
    required int col,
    required int availableMomentum,
  }) {
    if (row < 0 || col < 0 || row >= camp.gridSize || col >= camp.gridSize) {
      return ExpandCampTileResult(
        camp: camp,
        failure: 'Tile out of bounds.',
      );
    }

    final tile = camp.tileAt(row, col);
    if (tile == null || tile.status != CampTileStatus.locked) {
      return ExpandCampTileResult(
        camp: camp,
        failure: 'Tile cannot be expanded.',
      );
    }

    if (!camp.isAdjacentToUnlocked(row, col)) {
      return ExpandCampTileResult(
        camp: camp,
        failure: 'Expand adjacent to an open tile.',
      );
    }

    if (availableMomentum < GamificationConstants.momentumPerTileExpand) {
      return ExpandCampTileResult(
        camp: camp,
        failure: 'Not enough Momentum.',
      );
    }

    final updatedTiles = camp.tiles.map((t) {
      if (t.row == row && t.col == col) {
        return t.copyWith(status: CampTileStatus.unlocked);
      }
      return t;
    }).toList();

    return ExpandCampTileResult(
      camp: camp.copyWith(
        tiles: updatedTiles,
        spentMomentum:
            camp.spentMomentum + GamificationConstants.momentumPerTileExpand,
        weeklyAltitude: camp.weeklyAltitude + 2,
      ),
    );
  }
}
