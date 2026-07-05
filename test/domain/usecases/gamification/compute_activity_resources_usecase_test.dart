import 'package:flutter_test/flutter_test.dart';
import 'package:kynos/core/constants/gamification_constants.dart';
import 'package:kynos/domain/entities/health_summary.dart';
import 'package:kynos/domain/usecases/gamification/compute_activity_resources_usecase.dart';

void main() {
  const useCase = ComputeActivityResourcesUseCase();

  test('converts steps and calories to move points and stamina', () {
    final summary = HealthSummary(
      date: DateTime(2026, 7, 5),
      steps: 10000,
      activeCalories: 500,
    );

    final result = useCase(summary: summary, spentMovePoints: 0, spentStamina: 0);

    expect(result.totalMovePoints, 20);
    expect(result.totalStamina, 20);
    expect(result.availableMovePoints, 20);
    expect(result.availableStamina, 20);
  });

  test('caps move points and stamina at constants', () {
    final summary = HealthSummary(
      date: DateTime(2026, 7, 5),
      steps: 50000,
      activeCalories: 2000,
    );

    final result = useCase(summary: summary, spentMovePoints: 0, spentStamina: 0);

    expect(result.totalMovePoints, GamificationConstants.maxMovePoints);
    expect(result.totalStamina, GamificationConstants.maxStamina);
  });

  test('grants bonus move when workout logged today', () {
    final summary = HealthSummary(
      date: DateTime(2026, 7, 5),
      steps: 2000,
      activeCalories: 100,
      runningWorkoutCount: 1,
    );

    final result = useCase(summary: summary, spentMovePoints: 0, spentStamina: 0);

    expect(result.totalMovePoints, 5);
  });

  test('returns practice resources when health summary is null', () {
    final result = useCase(summary: null, spentMovePoints: 1, spentStamina: 2);

    expect(result.totalMovePoints, GamificationConstants.practiceMovePoints);
    expect(result.totalStamina, GamificationConstants.practiceStamina);
    expect(result.availableMovePoints, 2);
    expect(result.availableStamina, 6);
  });
}
