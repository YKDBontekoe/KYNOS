import 'package:flutter_test/flutter_test.dart';
import 'package:kynos/domain/entities/gamification/camp_building.dart';
import 'package:kynos/domain/entities/gamification/camp_state.dart';
import 'package:kynos/domain/entities/gamification/camp_tile.dart';
import 'package:kynos/domain/usecases/gamification/build_camp_structure_usecase.dart';
import 'package:kynos/domain/usecases/gamification/expand_camp_tile_usecase.dart';

void main() {
  const expandUseCase = ExpandCampTileUseCase();
  const buildUseCase = BuildCampStructureUseCase();

  test('expands adjacent locked tile with momentum', () {
    final camp = CampState.initial();
    const center = CampState.defaultGridSize ~/ 2;

    final result = expandUseCase(
      camp: camp,
      row: center,
      col: center + 1,
      availableMomentum: 5,
    );

    expect(result.isSuccess, isTrue);
    expect(result.camp.tileAt(center, center + 1)?.status,
        CampTileStatus.unlocked);
    expect(result.camp.spentMomentum, 2);
  });

  test('places building on unlocked tile with fuel', () {
    final camp = CampState.initial();
    const center = CampState.defaultGridSize ~/ 2;

    final result = buildUseCase(
      camp: camp,
      row: center,
      col: center,
      type: CampBuildingType.trackLoop,
      availableFuel: 10,
    );

    expect(result.isSuccess, isTrue);
    expect(result.camp.buildingAt(center, center)?.type,
        CampBuildingType.trackLoop);
    expect(result.camp.tileAt(center, center)?.isBuilt, isTrue);
  });
}
