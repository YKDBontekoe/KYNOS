import 'package:kynos/core/constants/gamification_constants.dart';
import 'package:kynos/domain/entities/gamification/character_class.dart';
import 'package:kynos/domain/entities/gamification/character_stats.dart';
import 'package:kynos/domain/entities/gamification/encounter_state.dart';
import 'package:kynos/domain/entities/gamification/runner_character.dart';

/// Result of a single combat turn.
class EncounterTurnResult {
  const EncounterTurnResult({
    required this.encounter,
    required this.staminaCost,
    required this.xpReward,
    required this.statDeltas,
  });

  final EncounterState encounter;
  final int staminaCost;
  final int xpReward;
  final Map<CharacterStatId, int> statDeltas;
}

class ResolveEncounterTurnUseCase {
  const ResolveEncounterTurnUseCase();

  EncounterTurnResult call({
    required RunnerCharacter character,
    required EncounterState encounter,
    required CombatAction action,
    required int availableStamina,
  }) {
    if (!encounter.isActive) {
      return EncounterTurnResult(
        encounter: encounter,
        staminaCost: 0,
        xpReward: 0,
        statDeltas: const {},
      );
    }

    final staminaCost = _staminaCost(action, character);
    final freeAction = encounter.firstActionFree &&
        character.characterClass is Phantom &&
        action != CombatAction.recover;

    if (!freeAction && staminaCost > availableStamina) {
      return EncounterTurnResult(
        encounter: encounter.copyWith(
          combatLog: [
            ...encounter.combatLog,
            'Not enough stamina for ${action.label}.',
          ].take(3).toList(),
        ),
        staminaCost: 0,
        xpReward: 0,
        statDeltas: const {},
      );
    }

    final paidCost = freeAction ? 0 : staminaCost;
    var state = encounter.copyWith(
      turnCount: encounter.turnCount + 1,
      firstActionFree: freeAction ? false : encounter.firstActionFree,
    );

    final log = <String>[];

    switch (action) {
      case CombatAction.strike:
        final damage = _damage(
          stat: character.stats[CharacterStatId.strength],
          multiplier: state.focusedNextTurn ? 1.4 : 1.0,
          seed: encounter.enemyId.hashCode + state.turnCount,
        );
        state = _applyPlayerDamage(state, damage, log, 'Strike');
        state = state.copyWith(focusedNextTurn: false);
      case CombatAction.rush:
        final accuracy = _roll(
              encounter.enemyId.hashCode + state.turnCount * 3,
            ) %
            100;
        if (accuracy < 25) {
          log.add('Rush missed!');
        } else {
          var multiplier = state.focusedNextTurn ? 1.6 : 1.3;
          if (character.characterClass is Surge) multiplier *= 1.2;
          final damage = _damage(
            stat: character.stats[CharacterStatId.speed],
            multiplier: multiplier,
            seed: encounter.enemyId.hashCode + state.turnCount,
          );
          state = _applyPlayerDamage(state, damage, log, 'Rush');
        }
        state = state.copyWith(focusedNextTurn: false);
      case CombatAction.brace:
        state = state.copyWith(blockingNextHit: true);
        log.add('Braced for impact.');
      case CombatAction.focus:
        state = state.copyWith(focusedNextTurn: true);
        log.add('Focused. Next attack hits harder.');
      case CombatAction.recover:
        log.add('Recovered composure.');
    }

    if (state.isActive && action != CombatAction.brace) {
      state = _enemyCounterAttack(state, character, log);
    }

    var xpReward = 0;
    var statDeltas = <CharacterStatId, int>{};

    if (state.outcome == EncounterOutcome.victory) {
      xpReward = state.isBoss
          ? GamificationConstants.encounterXpBoss
          : GamificationConstants.encounterXpNormal;
      statDeltas = {
        CharacterStatId.strength: 1,
        CharacterStatId.willpower: 1,
      };
    }

    return EncounterTurnResult(
      encounter: state.copyWith(
        combatLog: [...state.combatLog, ...log].take(3).toList(),
      ),
      staminaCost: paidCost,
      xpReward: xpReward,
      statDeltas: statDeltas,
    );
  }

  EncounterState startEncounter({
    required RunnerCharacter character,
    required String enemyId,
    required bool isBoss,
  }) {
    final maxHp = GamificationConstants.enemyBaseHp +
        character.level * GamificationConstants.enemyHpPerLevel +
        (isBoss ? 30 : 0);
    return EncounterState(
      enemyId: enemyId,
      enemyMaxHp: maxHp,
      enemyHp: maxHp,
      turnCount: 0,
      outcome: EncounterOutcome.inProgress,
      isBoss: isBoss,
    );
  }

  int _staminaCost(CombatAction action, RunnerCharacter character) {
    final base = switch (action) {
      CombatAction.strike => 4,
      CombatAction.rush => 6,
      CombatAction.brace => 3,
      CombatAction.focus => 2,
      CombatAction.recover => 5,
    };
    if (action == CombatAction.brace && character.characterClass is Iron) {
      return (base - 1).clamp(1, base);
    }
    return base;
  }

  int _damage({
    required int stat,
    required double multiplier,
    required int seed,
  }) {
    final variance = (_roll(seed) % 5) - 2;
    return ((stat / 10) * 12 * multiplier + variance).round().clamp(3, 80);
  }

  EncounterState _applyPlayerDamage(
    EncounterState state,
    int damage,
    List<String> log,
    String label,
  ) {
    final newHp = (state.enemyHp - damage).clamp(0, state.enemyMaxHp);
    log.add('$label dealt $damage damage.');
    if (newHp <= 0) {
      return state.copyWith(
        enemyHp: 0,
        outcome: EncounterOutcome.victory,
      );
    }
    return state.copyWith(enemyHp: newHp);
  }

  EncounterState _enemyCounterAttack(
    EncounterState state,
    RunnerCharacter character,
    List<String> log,
  ) {
    if (state.blockingNextHit) {
      log.add('Blocked the counter.');
      return state.copyWith(blockingNextHit: false);
    }

    final enemyDamage = _damage(
      stat: 20 + character.level,
      multiplier: state.isBoss ? 1.2 : 0.9,
      seed: state.enemyId.hashCode + state.turnCount * 7,
    );

    final endurance = character.stats[CharacterStatId.endurance];
    final mitigated = (enemyDamage * (1 - endurance / 200)).round().clamp(2, 40);

    if (mitigated >= character.stats[CharacterStatId.recovery] && state.turnCount > 6) {
      log.add('Overwhelmed after $mitigated damage.');
      return state.copyWith(outcome: EncounterOutcome.defeat);
    }

    log.add('Enemy hit for $mitigated.');
    return state;
  }

  int _roll(int seed) => (seed * 1103515245 + 12345) & 0x7fffffff;
}
