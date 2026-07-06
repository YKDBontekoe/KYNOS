import 'package:flutter_test/flutter_test.dart';
import 'package:kynos/domain/entities/gamification/camp_state.dart';
import 'package:kynos/domain/entities/gamification/character_class.dart';
import 'package:kynos/domain/entities/gamification/character_stats.dart';
import 'package:kynos/domain/entities/gamification/runner_character.dart';
import 'package:kynos/domain/entities/workout_session.dart';
import 'package:kynos/domain/usecases/gamification/generate_camp_quests_usecase.dart';
import 'package:kynos/domain/usecases/gamification/resolve_expedition_usecase.dart';
import 'package:kynos/domain/usecases/gamification/rest_camp_usecase.dart';

void main() {
  final character = RunnerCharacter(
    characterClass: const Apex(),
    level: 5,
    xp: 500,
    stats: const CharacterStats(),
    createdAt: DateTime(2026, 1, 1),
    lastUpdated: DateTime(2026, 1, 1),
  );

  test('generate camp quests emits three measurable quests', () {
    const useCase = GenerateCampQuestsUseCase();
    final quests = useCase(
      character: character,
      readinessScore: 70,
      referenceTime: DateTime(2026, 7, 6),
    );

    expect(quests.length, 3);
    expect(quests.every((q) => q.measurableObjective?.isMeasurable ?? false),
        isTrue);
  });

  test('rest camp spends focus and sets multiplier', () {
    const useCase = RestCampUseCase();
    final camp = CampState.initial();

    final result = useCase(
      camp: camp,
      availableFocus: 5,
      now: DateTime(2026, 7, 6),
      sleepHours: 8,
      readiness: 80,
    );

    expect(result.isSuccess, isTrue);
    expect(result.camp.restMultiplier, greaterThan(1));
    expect(result.camp.lastRestDate, isNotNull);
  });

  test('resolve expedition awards xp from run distance', () {
    const useCase = ResolveExpeditionUseCase();
    final run = WorkoutSession(
      id: 'run-1',
      start: DateTime(2026, 7, 6, 8),
      end: DateTime(2026, 7, 6, 8, 45),
      workoutType: 'running',
      distanceMeters: 6000,
      sourceName: 'test',
    );

    final result = useCase(
      character: character,
      run: run,
      expeditionUsedToday: false,
    );

    expect(result.isSuccess, isTrue);
    expect(result.event.xpReward, greaterThan(0));
  });
}
