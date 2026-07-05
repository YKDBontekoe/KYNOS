import 'package:flutter_test/flutter_test.dart';
import 'package:kynos/core/errors/failures.dart';
import 'package:kynos/domain/entities/gamification/adventure_session.dart';
import 'package:kynos/domain/entities/gamification/trail_node.dart';
import 'package:kynos/infrastructure/gamification/character_persistence_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('CharacterPersistenceRepository adventure session', () {
    late CharacterPersistenceRepository repo;

    setUp(() {
      repo = CharacterPersistenceRepository();
    });

    test('round-trips adventure session JSON', () async {
      final session = AdventureSession(
        date: DateTime(2026, 7, 6),
        nodes: const [
          TrailNode(index: 0, type: TrailNodeType.start, enemyId: 'none'),
          TrailNode(
            index: 1,
            type: TrailNodeType.encounter,
            enemyId: 'trail_grunt_0',
            resolved: true,
          ),
        ],
        currentIndex: 1,
        spentMovePoints: 1,
        spentStamina: 2,
        trailCompleted: false,
      );

      final saveFailure = await repo.saveAdventureSession(session);
      expect(saveFailure, isNull);

      final loadResult = await repo.loadAdventureSession();
      expect(loadResult.failure, isNull);
      expect(loadResult.session, isNotNull);
      expect(loadResult.session!.currentIndex, 1);
      expect(loadResult.session!.nodes.length, 2);
      expect(loadResult.session!.nodes[1].resolved, isTrue);
    });

    test('returns null session when nothing is stored', () async {
      final loadResult = await repo.loadAdventureSession();
      expect(loadResult.failure, isNull);
      expect(loadResult.session, isNull);
    });

    test('maps corrupt JSON to StorageFailure', () async {
      SharedPreferences.setMockInitialValues({
        'kynos_adventure_session_v1': '{not-json',
      });

      final loadResult = await repo.loadAdventureSession();
      expect(loadResult.session, isNull);
      expect(loadResult.failure, isA<StorageFailure>());
    });
  });
}
