import 'package:flutter_test/flutter_test.dart';
import 'package:kynos/domain/entities/gamification/quest.dart';
import 'package:kynos/domain/entities/health_summary.dart';
import 'package:kynos/domain/usecases/gamification/evaluate_quest_progress_usecase.dart';

void main() {
  const useCase = EvaluateQuestProgressUseCase();

  test('tracks sleep hours and exercise minutes objectives', () {
    final sleepQuest = Quest(
      id: 'sleep',
      type: QuestType.daily,
      difficulty: QuestDifficulty.easy,
      title: 'Rest',
      narrative: 'Sleep',
      objective: '7h',
      status: QuestStatus.active,
      xpReward: 80,
      statRewards: const {},
      generatedAt: DateTime(2026, 7, 6),
      expiresAt: DateTime(2026, 7, 6, 23, 59),
      measurableObjective: const QuestObjective(
        kind: QuestObjectiveKind.sleepHours,
        target: 7,
      ),
    );

    final summary = HealthSummary(
      date: DateTime(2026, 7, 6),
      sleepHours: 7.5,
      exerciseMinutes: 25,
    );

    expect(useCase.isComplete(quest: sleepQuest, summary: summary), isTrue);

    final moveQuest = sleepQuest.copyWith(
      measurableObjective: const QuestObjective(
        kind: QuestObjectiveKind.exerciseMinutes,
        target: 30,
      ),
    );

    expect(useCase.progressFraction(quest: moveQuest, summary: summary),
        closeTo(25 / 30, 0.01));
  });
}
