import 'package:kynos/core/constants/gamification_constants.dart';
import 'package:kynos/domain/entities/gamification/character_stats.dart';
import 'package:kynos/domain/entities/gamification/quest.dart';
import 'package:kynos/domain/entities/gamification/runner_character.dart';

/// Generates three measurable daily camp quests — one per health pillar.
class GenerateCampQuestsUseCase {
  const GenerateCampQuestsUseCase();

  List<Quest> call({
    required RunnerCharacter character,
    required double readinessScore,
    DateTime? referenceTime,
  }) {
    final now = referenceTime ?? DateTime.now();
    final expires =
        DateTime(now.year, now.month, now.day, 23, 59, 59);
    final difficulty = readinessScore >= 60
        ? QuestDifficulty.normal
        : QuestDifficulty.easy;
    final xp = difficulty == QuestDifficulty.normal ? 150 : 100;
    final ts = now.millisecondsSinceEpoch;

    return [
      _momentumQuest(
        id: 'camp_momentum_$ts',
        difficulty: difficulty,
        xp: xp,
        readiness: readinessScore,
        now: now,
        expires: expires,
      ),
      _fuelQuest(
        id: 'camp_fuel_$ts',
        difficulty: difficulty,
        xp: xp,
        readiness: readinessScore,
        now: now,
        expires: expires,
      ),
      _focusQuest(
        id: 'camp_focus_$ts',
        difficulty: difficulty,
        xp: xp,
        readiness: readinessScore,
        now: now,
        expires: expires,
      ),
    ];
  }

  Quest _momentumQuest({
    required String id,
    required QuestDifficulty difficulty,
    required int xp,
    required double readiness,
    required DateTime now,
    required DateTime expires,
  }) {
    final useSteps = now.day.isEven;
    if (useSteps) {
      final target = readiness >= 60
          ? GamificationConstants.questStepsNormal
          : GamificationConstants.questStepsEasy;
      return Quest(
        id: id,
        type: QuestType.daily,
        difficulty: difficulty,
        title: 'Trail Blazer',
        narrative: 'Every step unlocks new camp ground.',
        objective: 'Reach ${target.toInt()} steps today.',
        status: QuestStatus.active,
        xpReward: xp,
        statRewards: {CharacterStatId.endurance: 2, CharacterStatId.speed: 1},
        generatedAt: now,
        expiresAt: expires,
        measurableObjective: QuestObjective(
          kind: QuestObjectiveKind.steps,
          target: target,
        ),
      );
    }

    final target = readiness >= 60
        ? GamificationConstants.questExerciseMinNormal
        : GamificationConstants.questExerciseMinEasy;
    return Quest(
      id: id,
      type: QuestType.daily,
      difficulty: difficulty,
      title: 'Movement Minutes',
      narrative: 'Active minutes fuel camp expansion.',
      objective: 'Log ${target.toInt()} exercise minutes today.',
      status: QuestStatus.active,
      xpReward: xp,
      statRewards: {CharacterStatId.endurance: 2, CharacterStatId.speed: 1},
      generatedAt: now,
      expiresAt: expires,
      measurableObjective: QuestObjective(
        kind: QuestObjectiveKind.exerciseMinutes,
        target: target,
      ),
    );
  }

  Quest _fuelQuest({
    required String id,
    required QuestDifficulty difficulty,
    required int xp,
    required double readiness,
    required DateTime now,
    required DateTime expires,
  }) {
    final target = readiness >= 60
        ? GamificationConstants.questCaloriesNormal
        : GamificationConstants.questCaloriesEasy;
    return Quest(
      id: id,
      type: QuestType.daily,
      difficulty: difficulty,
      title: 'Fuel the Forge',
      narrative: 'Burn energy to build camp structures.',
      objective: 'Burn ${target.toInt()} active calories today.',
      status: QuestStatus.active,
      xpReward: xp,
      statRewards: {CharacterStatId.strength: 2, CharacterStatId.recovery: 1},
      generatedAt: now,
      expiresAt: expires,
      measurableObjective: QuestObjective(
        kind: QuestObjectiveKind.activeCalories,
        target: target,
      ),
    );
  }

  Quest _focusQuest({
    required String id,
    required QuestDifficulty difficulty,
    required int xp,
    required double readiness,
    required DateTime now,
    required DateTime expires,
  }) {
    final target = readiness >= 60
        ? GamificationConstants.questSleepNormal
        : GamificationConstants.questSleepEasy;
    return Quest(
      id: id,
      type: QuestType.daily,
      difficulty: difficulty,
      title: 'Camp Rest',
      narrative: 'Recovery powers tomorrow\'s climb.',
      objective: 'Sleep ${target.toStringAsFixed(1)} hours tonight.',
      status: QuestStatus.active,
      xpReward: xp,
      statRewards: {CharacterStatId.recovery: 3, CharacterStatId.willpower: 1},
      generatedAt: now,
      expiresAt: expires,
      measurableObjective: QuestObjective(
        kind: QuestObjectiveKind.sleepHours,
        target: target,
      ),
    );
  }
}
