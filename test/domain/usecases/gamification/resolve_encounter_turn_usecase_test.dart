import 'package:flutter_test/flutter_test.dart';
import 'package:kynos/domain/entities/gamification/character_class.dart';
import 'package:kynos/domain/entities/gamification/character_stats.dart';
import 'package:kynos/domain/entities/gamification/encounter_state.dart';
import 'package:kynos/domain/entities/gamification/quest.dart';
import 'package:kynos/domain/entities/gamification/runner_character.dart';
import 'package:kynos/domain/entities/health_summary.dart';
import 'package:kynos/domain/entities/workout_session.dart';
import 'package:kynos/domain/usecases/gamification/evaluate_quest_progress_usecase.dart';
import 'package:kynos/domain/usecases/gamification/resolve_encounter_turn_usecase.dart';

void main() {
  group('EvaluateQuestProgressUseCase', () {
    const useCase = EvaluateQuestProgressUseCase();

    final quest = Quest(
      id: 'q1',
      type: QuestType.daily,
      difficulty: QuestDifficulty.normal,
      title: 'Steps',
      narrative: 'Walk',
      objective: '8000 steps',
      status: QuestStatus.active,
      xpReward: 100,
      statRewards: const {},
      generatedAt: DateTime(2026, 7, 5),
      expiresAt: DateTime(2026, 7, 5, 23, 59),
      measurableObjective: const QuestObjective(
        kind: QuestObjectiveKind.steps,
        target: 8000,
      ),
    );

    test('completes when steps meet target', () {
      final summary = HealthSummary(date: DateTime(2026, 7, 5), steps: 8500);

      expect(
        useCase.isComplete(quest: quest, summary: summary),
        isTrue,
      );
      expect(useCase.progressFraction(quest: quest, summary: summary), 1.0);
    });

    test('tracks run distance progress', () {
      final distanceQuest = quest.copyWith(
        measurableObjective: const QuestObjective(
          kind: QuestObjectiveKind.runDistanceKm,
          target: 5,
        ),
      );
      final runs = [
        WorkoutSession(
          id: '1',
          start: DateTime(2026, 7, 5, 8),
          end: DateTime(2026, 7, 5, 8, 30),
          workoutType: 'running',
          sourceName: 'test',
          distanceMeters: 3200,
        ),
        WorkoutSession(
          id: '2',
          start: DateTime(2026, 7, 5, 18),
          end: DateTime(2026, 7, 5, 18, 25),
          workoutType: 'running',
          sourceName: 'test',
          distanceMeters: 2000,
        ),
      ];

      expect(
        useCase.isComplete(quest: distanceQuest, todayRuns: runs),
        isTrue,
      );
    });
  });

  group('ResolveEncounterTurnUseCase', () {
    const useCase = ResolveEncounterTurnUseCase();
    final character = RunnerCharacter(
      characterClass: const Surge(),
      level: 5,
      xp: 0,
      stats: const CharacterStats(strength: 30, speed: 40),
      createdAt: DateTime(2026, 1, 1),
      lastUpdated: DateTime(2026, 1, 1),
    );

    test('strike reduces enemy hp and costs stamina', () {
      final encounter = useCase.startEncounter(
        character: character,
        enemyId: 'trail_grunt_0',
        isBoss: false,
      );

      final result = useCase(
        character: character,
        encounter: encounter,
        action: CombatAction.strike,
        availableStamina: 20,
      );

      expect(result.staminaCost, 4);
      expect(result.encounter.enemyHp, lessThan(encounter.enemyMaxHp));
    });

    test('iron class reduces brace stamina cost', () {
      final iron = character.copyWith(characterClass: const Iron());
      final encounter = useCase.startEncounter(
        character: iron,
        enemyId: 'trail_grunt_0',
        isBoss: false,
      );

      final result = useCase(
        character: iron,
        encounter: encounter,
        action: CombatAction.brace,
        availableStamina: 10,
      );

      expect(result.staminaCost, 2);
    });

    test('phantom first action is free', () {
      final phantom = character.copyWith(characterClass: const Phantom());
      final encounter = useCase.startEncounter(
        character: phantom,
        enemyId: 'trail_grunt_0',
        isBoss: false,
      );

      final result = useCase(
        character: phantom,
        encounter: encounter,
        action: CombatAction.strike,
        availableStamina: 0,
      );

      expect(result.staminaCost, 0);
      expect(result.encounter.firstActionFree, isFalse);
    });
  });
}
