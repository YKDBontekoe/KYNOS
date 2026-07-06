import 'package:kynos/core/errors/failures.dart';
import 'package:kynos/domain/entities/gamification/camp_building.dart';
import 'package:kynos/domain/entities/gamification/camp_resources.dart';
import 'package:kynos/domain/entities/gamification/camp_state.dart';
import 'package:kynos/domain/entities/gamification/character_stats.dart';
import 'package:kynos/domain/entities/gamification/expedition_event.dart';
import 'package:kynos/domain/utils/readiness_score.dart';
import 'package:kynos/shared/providers/character_providers.dart';
import 'package:kynos/shared/providers/gamification_providers.dart';
import 'package:kynos/shared/providers/health_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'camp_providers.g.dart';

class CampViewState {
  const CampViewState({
    required this.camp,
    required this.resources,
    this.lastExpedition,
  });

  final CampState camp;
  final CampResources resources;
  final ExpeditionEvent? lastExpedition;
}

@Riverpod(keepAlive: true)
class CampSessionNotifier extends _$CampSessionNotifier {
  bool _actionInFlight = false;

  @override
  Future<CampViewState?> build() async {
    final character = await ref.read(runnerCharacterProvider.future);
    if (character == null) return null;

    final repo = ref.read(characterRepositoryProvider);
    final now = DateTime.now();
    final loadResult = await repo.loadCampState();

    if (loadResult.failure != null) {
      throw loadResult.failure!;
    }

    CampState camp = loadResult.camp ?? CampState.initial(now: now);
    camp = ref.read(advanceWeeklySummitUseCaseProvider)(
      camp: camp,
      reference: now,
    );
    camp = camp.forCurrentDay(now);

    if (loadResult.camp == null ||
        camp.weekStart != loadResult.camp!.weekStart ||
        camp.dailyDate != loadResult.camp!.dailyDate) {
      final saveFailure = await repo.saveCampState(camp);
      if (saveFailure != null) throw saveFailure;
    }

    return _viewState(camp);
  }

  CampViewState _viewState(CampState camp, {ExpeditionEvent? expedition}) {
    final summary = ref.read(healthSummaryProvider).value;
    final readiness = readinessScoreOrDefault(summary);
    final resources = ref.read(computeCampResourcesUseCaseProvider)(
      summary: summary,
      camp: camp,
      readinessOverride: readiness,
    );
    return CampViewState(
      camp: camp,
      resources: resources,
      lastExpedition: expedition,
    );
  }

  Future<void> _persist(CampState camp, {ExpeditionEvent? expedition}) async {
    final repo = ref.read(characterRepositoryProvider);
    final failure = await repo.saveCampState(camp);
    if (failure != null) throw failure;
    state = AsyncData(_viewState(camp, expedition: expedition));
  }

  Future<void> expandTile(int row, int col) async {
    if (_actionInFlight) return;
    final current = state.value;
    if (current == null) return;

    _actionInFlight = true;
    try {
      final result = ref.read(expandCampTileUseCaseProvider)(
        camp: current.camp,
        row: row,
        col: col,
        availableMomentum: current.resources.availableMomentum,
      );
      if (!result.isSuccess) {
        throw StorageFailure(result.failure!);
      }
      await _persist(result.camp);
    } on Failure catch (failure, stackTrace) {
      state = AsyncError(failure, stackTrace);
    } finally {
      _actionInFlight = false;
    }
  }

  Future<void> buildStructure({
    required int row,
    required int col,
    required CampBuildingType type,
  }) async {
    if (_actionInFlight) return;
    final current = state.value;
    if (current == null) return;

    _actionInFlight = true;
    try {
      final result = ref.read(buildCampStructureUseCaseProvider)(
        camp: current.camp,
        row: row,
        col: col,
        type: type,
        availableFuel: current.resources.availableFuel,
      );
      if (!result.isSuccess) {
        throw StorageFailure(result.failure!);
      }
      await _persist(result.camp);
    } on Failure catch (failure, stackTrace) {
      state = AsyncError(failure, stackTrace);
    } finally {
      _actionInFlight = false;
    }
  }

  Future<void> restCamp() async {
    if (_actionInFlight) return;
    final current = state.value;
    if (current == null) return;

    _actionInFlight = true;
    try {
      final summary = ref.read(healthSummaryProvider).value;
      final result = ref.read(restCampUseCaseProvider)(
        camp: current.camp,
        availableFocus: current.resources.availableFocus,
        now: DateTime.now(),
        sleepHours: summary?.sleepHours ?? 0,
        readiness: readinessScoreOrDefault(summary),
      );
      if (!result.isSuccess) {
        throw StorageFailure(result.failure!);
      }
      await _persist(result.camp);
    } on Failure catch (failure, stackTrace) {
      state = AsyncError(failure, stackTrace);
    } finally {
      _actionInFlight = false;
    }
  }

  Future<ExpeditionEvent?> launchExpedition() async {
    if (_actionInFlight) return null;
    final current = state.value;
    if (current == null) return null;
    if (current.camp.expeditionUsedToday) return null;
    if (!current.resources.canSpendSpirit(3)) return null;

    _actionInFlight = true;
    try {
      final character = await ref.read(runnerCharacterProvider.future);
      if (character == null) return null;

      final runs = await ref.read(recentRunsProvider(days: 1, limit: 5).future);
      final today = DateTime.now();
      final todayRuns = runs.where((r) {
        final d = r.start;
        return d.year == today.year &&
            d.month == today.month &&
            d.day == today.day;
      }).toList();
      if (todayRuns.isEmpty) {
        throw const StorageFailure('Complete a run today first.');
      }

      final result = ref.read(resolveExpeditionUseCaseProvider)(
        character: character,
        run: todayRuns.first,
        expeditionUsedToday: current.camp.expeditionUsedToday,
      );
      if (!result.isSuccess) {
        throw StorageFailure(result.failure!);
      }

      final event = result.event;
      await _awardXp(event.xpReward, event.statDeltas);

      final updatedCamp = current.camp.copyWith(
        spentSpirit: current.camp.spentSpirit + 3,
        expeditionUsedToday: true,
        weeklyAltitude: current.camp.weeklyAltitude + event.summitBonus,
      );
      await _persist(updatedCamp, expedition: event);
      return event;
    } on Failure catch (failure, stackTrace) {
      state = AsyncError(failure, stackTrace);
      return null;
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
