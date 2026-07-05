import 'package:kynos/core/constants/gamification_constants.dart';
import 'package:kynos/domain/entities/gamification/activity_resources.dart';
import 'package:kynos/domain/entities/gamification/adventure_session.dart';
import 'package:kynos/domain/entities/gamification/character_stats.dart';
import 'package:kynos/domain/entities/gamification/encounter_state.dart';
import 'package:kynos/domain/entities/gamification/quest.dart';
import 'package:kynos/domain/entities/gamification/trail_node.dart';
import 'package:kynos/features/character/providers/character_provider.dart';
import 'package:kynos/features/character/providers/quest_provider.dart';
import 'package:kynos/shared/providers/daily_quests_provider.dart';
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
  @override
  Future<AdventureViewState?> build() async {
    final character = await ref.watch(runnerCharacterProvider.future);
    if (character == null) return null;

    ref.watch(healthSummaryProvider);
    await _syncMeasurableQuests();

    final repo = ref.read(characterRepositoryProvider);
    final today = DateTime.now();
    final loadResult = await repo.loadAdventureSession();

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
      await repo.saveAdventureSession(session);
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
    await repo.saveAdventureSession(session);
    state = AsyncData(_viewState(session));
  }

  Future<void> advance() async {
    final current = state.value;
    if (current == null) return;
    if (!current.resources.canAdvance) return;
    if (current.session.trailCompleted) return;
    if (current.session.activeEncounter?.isActive ?? false) return;

    var session = current.session;
    final nextIndex = (session.currentIndex + 1).clamp(0, session.nodes.length - 1);
    final node = session.nodes[nextIndex];

    var spentMove = session.spentMovePoints + 1;
    var bonusUsed = session.bonusMoveUsed;
    final summary = ref.read(healthSummaryProvider).value;
    if ((summary?.runningWorkoutCount ?? 0) >= 1 && !bonusUsed) {
      bonusUsed = true;
    }

    var nodes = [...session.nodes];
    nodes[nextIndex] = node.copyWith(resolved: true);

    session = session.copyWith(
      currentIndex: nextIndex,
      spentMovePoints: spentMove,
      bonusMoveUsed: bonusUsed,
      nodes: nodes,
    );

    session = await _resolveNode(session, node);

    if (nextIndex >= session.nodes.length - 1 && node.resolved) {
      session = session.copyWith(trailCompleted: true);
    }

    await _persist(session);
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
            .clamp(0, session.spentStamina);
        await _awardXp(GamificationConstants.treasureXp ~/ 2, const {});
        return session.copyWith(spentStamina: recovered);
      case TrailNodeType.treasure:
        await _awardXp(GamificationConstants.treasureXp, const {});
        return session;
    }
  }

  Future<void> performCombatAction(CombatAction action) async {
    final current = state.value;
    if (current == null) return;
    final encounter = current.session.activeEncounter;
    if (encounter == null || !encounter.isActive) return;

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
  }

  Future<void> retreatFromEncounter() async {
    final current = state.value;
    if (current == null) return;
    final encounter = current.session.activeEncounter;
    if (encounter == null) return;

    final updated = encounter.copyWith(outcome: EncounterOutcome.retreated);
    await _persist(
      current.session.copyWith(
        activeEncounter: updated,
        clearEncounter: true,
      ),
    );
  }

  Future<void> _awardXp(
    int amount,
    Map<CharacterStatId, int> statDeltas,
  ) async {
    if (amount <= 0 && statDeltas.isEmpty) return;
    final repo = ref.read(characterRepositoryProvider);
    final charResult = await repo.loadCharacter();
    final character = charResult.character;
    if (character == null) return;

    final updated = character.withXpGain(
      amount,
      statDeltas: statDeltas.isEmpty ? null : statDeltas,
    );
    await repo.saveCharacter(updated);
    ref.invalidate(runnerCharacterProvider);
  }

  Future<void> _syncMeasurableQuests() async {
    final quests = await ref.read(dailyQuestsProvider.future);
    if (quests.isEmpty) return;

    final evaluator = ref.read(evaluateQuestProgressUseCaseProvider);
    final summary = ref.read(healthSummaryProvider).value;
    final runs = await ref.read(recentRunsProvider(days: 1, limit: 20).future);
    final today = DateTime.now();
    final todayRuns = runs.where((r) => _isSameDay(r.start, today)).toList();

    for (final quest in quests) {
      if (quest.status != QuestStatus.active) continue;
      if (quest.measurableObjective == null) continue;
      if (!evaluator.isComplete(
        quest: quest,
        summary: summary,
        todayRuns: todayRuns,
      )) {
        continue;
      }
      await ref.read(questProvider.notifier).completeQuest(quest.id);
    }
  }
}
