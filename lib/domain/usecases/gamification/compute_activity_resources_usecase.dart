import 'package:kynos/core/constants/gamification_constants.dart';
import 'package:kynos/domain/entities/gamification/activity_resources.dart';
import 'package:kynos/domain/entities/health_summary.dart';

class ComputeActivityResourcesUseCase {
  const ComputeActivityResourcesUseCase();

  ActivityResources call({
    HealthSummary? summary,
    required int spentMovePoints,
    required int spentStamina,
    bool bonusMoveUsed = false,
  }) {
    if (summary == null) {
      return ActivityResources(
        totalMovePoints: GamificationConstants.practiceMovePoints,
        totalStamina: GamificationConstants.practiceStamina,
        spentMovePoints: spentMovePoints,
        spentStamina: spentStamina,
        bonusMoveGranted: bonusMoveUsed,
      );
    }

    final int steps = summary.steps ?? 0;
    final double calories = summary.activeCalories ?? 0;

    var movePoints = (steps ~/ GamificationConstants.stepsPerMovePoint)
        .clamp(0, GamificationConstants.maxMovePoints)
        .toInt();

    if ((summary.runningWorkoutCount ?? 0) >= 1 && !bonusMoveUsed) {
      movePoints = (movePoints + 1)
          .clamp(0, GamificationConstants.maxMovePoints)
          .toInt();
    }

    final stamina = (calories ~/ GamificationConstants.caloriesPerStamina)
        .clamp(0, GamificationConstants.maxStamina)
        .toInt();

    return ActivityResources(
      totalMovePoints: movePoints,
      totalStamina: stamina,
      spentMovePoints: spentMovePoints,
      spentStamina: spentStamina,
      bonusMoveGranted: bonusMoveUsed ||
          ((summary.runningWorkoutCount ?? 0) >= 1 && movePoints > 0),
    );
  }
}
