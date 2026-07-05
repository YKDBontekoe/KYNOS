import 'package:flutter_test/flutter_test.dart';
import 'package:kynos/domain/entities/gamification/quest.dart';
import 'package:kynos/domain/entities/health_summary.dart';
import 'package:kynos/domain/usecases/gamification/evaluate_quest_progress_usecase.dart';

void main() {
  const useCase = EvaluateQuestProgressUseCase();

  test('reports partial progress for active calories', () {
    final quest = Quest(
      id: 'q1',
      type: QuestType.daily,
      difficulty: QuestDifficulty.easy,
      title: 'Burn',
      narrative: 'Move',
      objective: '400 kcal',
      status: QuestStatus.active,
      xpReward: 80,
      statRewards: const {},
      generatedAt: DateTime(2026, 7, 5),
      expiresAt: DateTime(2026, 7, 5, 23, 59),
      measurableObjective: const QuestObjective(
        kind: QuestObjectiveKind.activeCalories,
        target: 400,
      ),
    );

    final summary = HealthSummary(
      date: DateTime(2026, 7, 5),
      activeCalories: 200,
    );

    expect(useCase.progressFraction(quest: quest, summary: summary), 0.5);
    expect(useCase.isComplete(quest: quest, summary: summary), isFalse);
  });
}
