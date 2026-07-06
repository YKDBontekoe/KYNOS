import 'package:kynos/core/constants/gamification_constants.dart';
import 'package:kynos/core/errors/failures.dart';
import 'package:kynos/domain/entities/gamification/activity_resources.dart';
import 'package:kynos/domain/entities/gamification/adventure_session.dart';
import 'package:kynos/domain/entities/gamification/character_stats.dart';
import 'package:kynos/domain/entities/gamification/encounter_state.dart';
import 'package:kynos/domain/entities/gamification/trail_node.dart';
import 'package:kynos/features/character/providers/character_provider.dart';
import 'package:kynos/shared/providers/gamification_providers.dart';
import 'package:kynos/shared/providers/health_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'adventure_provider.g.dart';

class AdventureViewState {
  const AdventureViewState({
    required this.session,
    required this.resources,
  });

  final AdventureSession session;
  final ActivityResources resources;
}

bool _isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

@Riverpod(keepAlive: true)
class AdventureSessionNotifier extends _$AdventureSessionNotifier {
  bool _actionInFlight = false;

  @override
  Future<AdventureViewState?> build() async {
    final character = await ref.read(runnerCharacterProvider.future);
    if (character == null) return null;

    final repo = ref.read(characterRepositoryProvider);
    final today = DateTime.now();
    final loadResult = await repo.loadAdventureSession();

    if (loadResult.failure != null) {
      throw loadResult.failure!;
    }

    AdventureSession session;
    if (loadResult.session != null &&
        _isSameDay(loadResult.session!.date, today)) {
      session = loadResult.session!;
    } else {
      final trail = ref.read(generateDailyTrailUseCaseProvider)(
        characterLevel: character.level,
        date: today,
      );
      session = AdventureSession(
        date: DateTime(today.year, today.month, today.day),
        nodes: trail,
        currentIndex: 0,
        spentMovePoints: 0,
        spentStamina: 0,
      );
      final saveFailure = await repo.saveAdventureSession(session);
      if (saveFailure != null) {
        throw saveFailure;
      }
    }

    return _viewState(session);
  }

  AdventureViewState _viewState(AdventureSession session) {
    final summary = ref.read(healthSummaryProvider).value;
    final resources = ref.read(computeActivityResourcesUseCaseProvider)(
      summary: summary,
      spentMovePoints: session.spentMovePoints,
      spentStamina: session.spentStamina,
      bonusMoveUsed: session.bonusMoveUsed,
    );
    return AdventureViewState(session: session, resources: resources);
  }

  Future<void> _persist(AdventureSession session) async {
    final repo = ref.read(characterRepositoryProvider);
    final failure = await repo.saveAdventureSession(session);
    if (failure != null) {
      throw failure;
    }
    state = AsyncData(_viewState(session));
  }

  Future<void> advance() async {
    if (_actionInFlight) return;
    final current = state.value;
    if (current == null) return;
    if (!current.resources.canAdvance) return;
    if (current.session.trailCompleted) return;
    if (current.session.activeEncounter?.isActive ?? false) return;

    _actionInFlight = true;
    try {
      var session = current.session;
      final nextIndex = (session.currentIndex + 1)
          .clamp(0, session.nodes.length - 1)
          .toInt();
      final node = session.nodes[nextIndex];

      final spentMove = session.spentMovePoints + 1;
      var bonusUsed = session.bonusMoveUsed;
      final summary = ref.read(healthSummaryProvider).value;
      if ((summary?.runningWorkoutCount ?? 0) >= 1 && !bonusUsed) {
        bonusUsed = true;
      }

      final nodes = [...session.nodes];
      nodes[nextIndex] = node.copyWith(resolved: true);

      session = session.copyWith(
        currentIndex: nextIndex,
        spentMovePoints: spentMove,
        bonusMoveUsed: bonusUsed,
        nodes: nodes,
      );

      session = await _resolveNode(session, nodes[nextIndex]);

      if (nextIndex >= session.nodes.length - 1 &&
          session.nodes[nextIndex].resolved) {
        session = session.copyWith(trailCompleted: true);
      }

      await _persist(session);
    } on Failure catch (failure, stackTrace) {
      state = AsyncError(failure, stackTrace);
    } finally {
      _actionInFlight = false;
    }
  }

  Future<AdventureSession> _resolveNode(
    AdventureSession session,
    TrailNode node,
  ) async {
    final character = await ref.read(runnerCharacterProvider.future);
    if (character == null) return session;

    switch (node.type) {
      case TrailNodeType.start:
        return session;
      case TrailNodeType.encounter:
      case TrailNodeType.boss:
        final encounter = ref.read(resolveEncounterTurnUseCaseProvider)
            .startEncounter(
          character: character,
          enemyId: node.enemyId,
          isBoss: node.type == TrailNodeType.boss,
        );
        return session.copyWith(activeEncounter: encounter);
      case TrailNodeType.rest:
        final recovered = (session.spentStamina -
                GamificationConstants.restStaminaRecovery)
            .clamp(0, session.spentStamina)
            .toInt();
        await _awardXp(GamificationConstants.treasureXp ~/ 2, const {});
        return session.copyWith(spentStamina: recovered);
      case TrailNodeType.treasure:
        await _awardXp(GamificationConstants.treasureXp, const {});
        return session;
    }
  }

  Future<void> performCombatAction(CombatAction action) async {
    if (_actionInFlight) return;
    final current = state.value;
    if (current == null) return;
    final encounter = current.session.activeEncounter;
    if (encounter == null || !encounter.isActive) return;

    _actionInFlight = true;
    try {
      final character = await ref.read(runnerCharacterProvider.future);
      if (character == null) return;

      final result = ref.read(resolveEncounterTurnUseCaseProvider)(
        character: character,
        encounter: encounter,
        action: action,
        availableStamina: current.resources.availableStamina,
      );

      var session = current.session.copyWith(
        spentStamina: current.session.spentStamina + result.staminaCost,
        activeEncounter: result.encounter,
      );

      if (result.encounter.outcome == EncounterOutcome.victory) {
        await _awardXp(result.xpReward, result.statDeltas);
        session = session.copyWith(clearEncounter: true);
      } else if (result.encounter.outcome == EncounterOutcome.defeat) {
        session = session.copyWith(clearEncounter: true);
      }

      await _persist(session);
    } on Failure catch (failure, stackTrace) {
      state = AsyncError(failure, stackTrace);
    } finally {
      _actionInFlight = false;
    }
  }

  Future<void> retreatFromEncounter() async {
    if (_actionInFlight) return;
    final current = state.value;
    if (current == null) return;
    final encounter = current.session.activeEncounter;
    if (encounter == null) return;

    _actionInFlight = true;
    try {
      final updated = encounter.copyWith(outcome: EncounterOutcome.retreated);
      await _persist(
        current.session.copyWith(
          activeEncounter: updated,
          clearEncounter: true,
        ),
      );
    } on Failure catch (failure, stackTrace) {
      state = AsyncError(failure, stackTrace);
    } finally {
      _actionInFlight = false;
    }
  }

  Future<void> _awardXp(
    int amount,
    Map<CharacterStatId, int> statDeltas,
  ) async {
    if (amount <= 0 && statDeltas.isEmpty) return;
    final repo = ref.read(characterRepositoryProvider);
    final charResult = await repo.loadCharacter();
    if (charResult.failure != null) return;
    final character = charResult.character;
    if (character == null) return;

    final updated = character.withXpGain(
      amount,
      statDeltas: statDeltas.isEmpty ? null : statDeltas,
    );
    final saveFailure = await repo.saveCharacter(updated);
    if (saveFailure != null) return;
    ref.invalidate(runnerCharacterProvider);
  }
}
