import 'package:flutter_test/flutter_test.dart';
import 'package:kynos/domain/entities/gamification/encounter_state.dart';
import 'package:kynos/domain/entities/gamification/quest.dart';

void main() {
  group('QuestObjective.fromJson', () {
    test('downgrades corrupt measurable target to manual', () {
      final objective = QuestObjective.fromJson({
        'kind': QuestObjectiveKind.steps.name,
      });

      expect(objective.kind, QuestObjectiveKind.manual);
      expect(objective.isMeasurable, isFalse);
    });

    test('preserves valid measurable objective', () {
      final objective = QuestObjective.fromJson({
        'kind': QuestObjectiveKind.activeCalories.name,
        'target': 400,
      });

      expect(objective.kind, QuestObjectiveKind.activeCalories);
      expect(objective.target, 400);
      expect(objective.isMeasurable, isTrue);
    });
  });

  group('EncounterState.fromJson', () {
    test('uses defaults when hp fields are missing', () {
      final state = EncounterState.fromJson({
        'enemy_id': 'trail_grunt_0',
        'turn_count': 0,
        'outcome': EncounterOutcome.inProgress.name,
      });

      expect(state.enemyMaxHp, 40);
      expect(state.enemyHp, 40);
    });
  });
}
