import 'package:flutter_test/flutter_test.dart';
import 'package:kynos/domain/entities/gamification/camp_state.dart';
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

    test('supports sleep and exercise minute kinds', () {
      final sleep = QuestObjective.fromJson({
        'kind': QuestObjectiveKind.sleepHours.name,
        'target': 7.5,
      });
      final exercise = QuestObjective.fromJson({
        'kind': QuestObjectiveKind.exerciseMinutes.name,
        'target': 30,
      });

      expect(sleep.kind, QuestObjectiveKind.sleepHours);
      expect(exercise.kind, QuestObjectiveKind.exerciseMinutes);
    });
  });

  group('CampState.fromJson', () {
    test('creates initial grid when tiles missing', () {
      final camp = CampState.fromJson({'weekly_altitude': 12});

      expect(camp.tiles.length, CampState.defaultGridSize * CampState.defaultGridSize);
      expect(camp.weeklyAltitude, 12);
    });
  });
}
