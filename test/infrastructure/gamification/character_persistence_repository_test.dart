import 'package:flutter_test/flutter_test.dart';
import 'package:kynos/core/errors/failures.dart';
import 'package:kynos/domain/entities/gamification/camp_state.dart';
import 'package:kynos/infrastructure/gamification/character_persistence_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('CharacterPersistenceRepository camp state', () {
    late CharacterPersistenceRepository repo;

    setUp(() {
      repo = CharacterPersistenceRepository();
    });

    test('round-trips camp state JSON', () async {
      final camp = CampState.initial(now: DateTime(2026, 7, 6));

      final saveFailure = await repo.saveCampState(camp);
      expect(saveFailure, isNull);

      final loadResult = await repo.loadCampState();
      expect(loadResult.failure, isNull);
      expect(loadResult.camp, isNotNull);
      expect(loadResult.camp!.gridSize, CampState.defaultGridSize);
      expect(loadResult.camp!.weeklyGoal, 100);
    });

    test('returns null camp when nothing is stored', () async {
      final loadResult = await repo.loadCampState();
      expect(loadResult.failure, isNull);
      expect(loadResult.camp, isNull);
    });

    test('maps corrupt JSON to StorageFailure', () async {
      SharedPreferences.setMockInitialValues({
        'kynos_camp_state_v1': '{not-json',
      });

      final loadResult = await repo.loadCampState();
      expect(loadResult.camp, isNull);
      expect(loadResult.failure, isA<StorageFailure>());
    });
  });
}
