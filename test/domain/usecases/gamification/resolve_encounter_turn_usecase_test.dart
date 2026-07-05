import 'package:flutter_test/flutter_test.dart';
import 'package:kynos/domain/entities/gamification/character_class.dart';
import 'package:kynos/domain/entities/gamification/character_stats.dart';
import 'package:kynos/domain/entities/gamification/encounter_state.dart';
import 'package:kynos/domain/entities/gamification/runner_character.dart';
import 'package:kynos/domain/usecases/gamification/resolve_encounter_turn_usecase.dart';

void main() {
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
