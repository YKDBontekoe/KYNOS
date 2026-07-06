import 'package:flutter_test/flutter_test.dart';
import 'package:kynos/core/constants/gamification_constants.dart';
import 'package:kynos/domain/entities/gamification/camp_state.dart';
import 'package:kynos/domain/entities/health_summary.dart';
import 'package:kynos/domain/usecases/gamification/compute_camp_resources_usecase.dart';

void main() {
  const useCase = ComputeCampResourcesUseCase();
  final camp = CampState.initial();

  test('converts health metrics to four camp resources', () {
    final summary = HealthSummary(
      date: DateTime(2026, 7, 6),
      steps: 8000,
      exerciseMinutes: 30,
      activeCalories: 400,
      sleepHours: 7.5,
      runningWorkoutCount: 1,
    );

    final result = useCase(summary: summary, camp: camp);

    expect(result.totalMomentum, greaterThan(0));
    expect(result.totalFuel, 20);
    expect(result.totalFocus, greaterThan(0));
    expect(result.totalSpirit, GamificationConstants.spiritPerRun);
  });

  test('returns practice resources when health summary is null', () {
    final result = useCase(summary: null, camp: camp);

    expect(result.totalMomentum, GamificationConstants.practiceMomentum);
    expect(result.totalFuel, GamificationConstants.practiceFuel);
    expect(result.totalFocus, GamificationConstants.practiceFocus);
    expect(result.totalSpirit, GamificationConstants.practiceSpirit);
  });
}
