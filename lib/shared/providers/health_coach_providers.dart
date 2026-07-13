import 'package:kynos/domain/entities/health/health_coach_models.dart';
import 'package:kynos/domain/repositories/health_coach_repository.dart';
import 'package:kynos/domain/usecases/health/build_daily_health_brief_usecase.dart';
import 'package:kynos/infrastructure/health/prefs_health_coach_repository.dart';
import 'package:kynos/shared/providers/health_providers.dart';
import 'package:kynos/shared/providers/shared_preferences_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

part 'health_coach_providers.g.dart';

@riverpod
HealthCoachRepository healthCoachRepository(Ref ref) =>
    PrefsHealthCoachRepository(ref.watch(sharedPreferencesProvider));

@Riverpod(keepAlive: true)
class HealthCoachData extends _$HealthCoachData {
  @override
  Future<HealthCoachState> build() async {
    final result = await ref.watch(healthCoachRepositoryProvider).load();
    if (result.failure != null) throw result.failure!;
    return result.value ?? const HealthCoachState();
  }

  Future<void> saveCheckIn(HealthCheckIn checkIn) async {
    final current = state.value ?? const HealthCoachState();
    final day = DateTime(
      checkIn.date.year,
      checkIn.date.month,
      checkIn.date.day,
    );
    final next = current.copyWith(
      checkIns: [
        checkIn,
        ...current.checkIns.where((item) {
          final itemDay = DateTime(
            item.date.year,
            item.date.month,
            item.date.day,
          );
          return itemDay != day;
        }),
      ],
    );
    await _persist(next);
  }

  Future<void> confirmAction(PendingCoachAction action) async {
    final current = state.value ?? const HealthCoachState();
    switch (action.type) {
      case CoachActionType.saveMemory:
        if (current.memories.any((item) => item.id == action.id)) return;
        final fact = action.payload['fact']?.toString().trim();
        if (fact == null || fact.isEmpty) return;
        await _persist(
          current.copyWith(
            memories: [
              CoachMemory(
                id: action.id,
                fact: fact,
                provenance: 'Confirmed in coach conversation',
                createdAt: DateTime.now(),
                confirmed: true,
              ),
              ...current.memories,
            ],
          ),
        );
        return;
      case CoachActionType.createExperiment:
        if (current.experiments.any((item) => item.id == action.id)) return;
        final duration =
            int.tryParse(action.payload['durationDays']?.toString() ?? '') ?? 7;
        await _persist(
          current.copyWith(
            experiments: [
              WellbeingExperiment(
                id: action.id,
                title: action.title,
                action: action.payload['action']?.toString() ?? action.title,
                hypothesis: action.explanation,
                durationDays: duration.clamp(3, 14),
                createdAt: DateTime.now(),
                status: ExperimentStatus.active,
                outcomeMetrics: const [],
              ),
              ...current.experiments,
            ],
          ),
        );
        return;
    }
  }

  Future<void> logExperiment({
    required String id,
    required bool adhered,
  }) async {
    final current = state.value ?? const HealthCoachState();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final latestCheckIn = current.checkIns.where((item) {
      final date = DateTime(item.date.year, item.date.month, item.date.day);
      return date == today;
    }).firstOrNull;
    final experiments = current.experiments.map((experiment) {
      if (experiment.id != id || experiment.status != ExperimentStatus.active) {
        return experiment;
      }
      final logs = [
        ExperimentLog(
          date: today,
          adhered: adhered,
          energy: latestCheckIn?.energy,
          mood: latestCheckIn?.mood,
        ),
        ...experiment.logs.where((item) {
          final date = DateTime(item.date.year, item.date.month, item.date.day);
          return date != today;
        }),
      ];
      final completed = logs.length >= experiment.durationDays;
      return experiment.copyWith(
        logs: logs,
        status: completed ? ExperimentStatus.completed : experiment.status,
        result: completed
            ? 'Experiment completed. Ask KYNOS to compare adherence and how you felt.'
            : experiment.result,
      );
    }).toList();
    await _persist(current.copyWith(experiments: experiments));
  }

  Future<void> cancelExperiment(String id) async {
    final current = state.value ?? const HealthCoachState();
    await _persist(
      current.copyWith(
        experiments: current.experiments
            .map(
              (item) => item.id == id
                  ? item.copyWith(status: ExperimentStatus.cancelled)
                  : item,
            )
            .toList(),
      ),
    );
  }

  Future<void> deleteMemory(String id) async {
    final current = state.value ?? const HealthCoachState();
    await _persist(
      current.copyWith(
        memories: current.memories.where((item) => item.id != id).toList(),
      ),
    );
  }

  Future<void> clearAll() async {
    final previous = state.value ?? const HealthCoachState();
    final result = await ref.read(healthCoachRepositoryProvider).clear();
    if (result.failure != null) {
      state = AsyncError(result.failure!, StackTrace.current);
      if (state.value == null) state = AsyncData(previous);
      return;
    }
    state = const AsyncData(HealthCoachState());
  }

  Future<void> _persist(HealthCoachState next) async {
    final previous = state.value ?? const HealthCoachState();
    final result = await ref.read(healthCoachRepositoryProvider).save(next);
    if (result.failure != null) {
      state = AsyncError(result.failure!, StackTrace.current);
      if (state.value == null) state = AsyncData(previous);
      return;
    }
    state = AsyncData(next);
  }
}

@riverpod
Future<DailyHealthBrief> dailyHealthBrief(Ref ref) async {
  final history = await ref.watch(healthHistoryProvider(days: 29).future);
  final coachData = await ref.watch(healthCoachDataProvider.future);
  final now = DateTime.now();
  HealthCheckIn? checkIn;
  for (final item in coachData.checkIns) {
    if (item.date.year == now.year &&
        item.date.month == now.month &&
        item.date.day == now.day) {
      checkIn = item;
      break;
    }
  }
  return const BuildDailyHealthBriefUseCase().call(
    history: history,
    checkIn: checkIn,
    now: now,
  );
}

@riverpod
PendingCoachAction experimentProposal(
  Ref ref, {
  required String title,
  required String action,
  required String hypothesis,
  int durationDays = 7,
}) => PendingCoachAction(
  id: const Uuid().v4(),
  type: CoachActionType.createExperiment,
  title: title,
  explanation: hypothesis,
  payload: {'action': action, 'durationDays': durationDays.clamp(3, 14)},
);
