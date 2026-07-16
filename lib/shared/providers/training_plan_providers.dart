import 'dart:convert';

import 'package:kynos/domain/entities/coach/today_directive.dart';
import 'package:kynos/domain/entities/coach/training_plan.dart';
import 'package:kynos/domain/entities/health/health_coach_models.dart';
import 'package:kynos/domain/repositories/training_plan_repository.dart';
import 'package:kynos/domain/usecases/coach/log_plan_adherence_usecase.dart';
import 'package:kynos/domain/utils/acwr.dart';
import 'package:kynos/domain/utils/readiness_score.dart';
import 'package:kynos/infrastructure/coach/prefs_training_plan_repository.dart';
import 'package:kynos/shared/providers/coach_personalization_provider.dart';
import 'package:kynos/shared/providers/coach_usecase_providers.dart';
import 'package:kynos/shared/providers/health_coach_providers.dart';
import 'package:kynos/shared/providers/health_providers.dart';
import 'package:kynos/shared/providers/shared_preferences_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'training_plan_providers.g.dart';

@riverpod
TrainingPlanRepository trainingPlanRepository(Ref ref) =>
    PrefsTrainingPlanRepository(ref.watch(sharedPreferencesProvider));

@Riverpod(keepAlive: true)
class TrainingPlanData extends _$TrainingPlanData {
  static const _logAdherence = LogPlanAdherenceUseCase();

  @override
  Future<TrainingPlan?> build() async {
    final result = await ref.watch(trainingPlanRepositoryProvider).loadActive();
    if (result.failure != null) throw result.failure!;
    return result.value;
  }

  Future<void> activateFromAction(PendingCoachAction action) async {
    final raw = action.payload['planJson']?.toString();
    if (raw == null || raw.isEmpty) return;
    final decoded = jsonDecode(raw);
    if (decoded is! Map) return;
    final plan = TrainingPlan.fromJson(
      Map<String, Object?>.from(decoded),
    ).copyWith(active: true);
    await _persist(plan);
  }

  Future<void> markDone({String? note}) async {
    await _setTodayAdherence(PlanAdherenceStatus.done, note: note);
  }

  Future<void> markSkipped({String? note}) async {
    await _setTodayAdherence(PlanAdherenceStatus.skipped, note: note);
  }

  Future<void> clear() async {
    final result = await ref.read(trainingPlanRepositoryProvider).clear();
    if (result.failure != null) throw result.failure!;
    state = const AsyncData(null);
  }

  Future<void> _setTodayAdherence(
    PlanAdherenceStatus status, {
    String? note,
  }) async {
    final current = state.value;
    if (current == null) return;
    final updated = _logAdherence(
      plan: current,
      date: DateTime.now(),
      status: status,
      note: note,
    );
    await _persist(updated);
  }

  Future<void> _persist(TrainingPlan plan) async {
    final result = await ref.read(trainingPlanRepositoryProvider).save(plan);
    if (result.failure != null) throw result.failure!;
    state = AsyncData(plan);
  }
}

@riverpod
TodayDirective todayDirective(Ref ref) {
  final plan = ref.watch(trainingPlanDataProvider).value;
  final personalization = ref.watch(coachPersonalizationProvider);
  final healthCoach = ref.watch(healthCoachDataProvider).value;
  final healthHistory = ref.watch(healthHistoryProvider(days: 28)).value ?? [];
  final recentRuns =
      ref.watch(recentRunsProvider(days: 60, limit: 5)).value ?? [];

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final todayCheckIn = healthCoach?.checkIns.where((item) {
    final day = DateTime(item.date.year, item.date.month, item.date.day);
    return day == today;
  }).firstOrNull;

  final sortedHistory = List.of(healthHistory)
    ..sort((a, b) => b.date.compareTo(a.date));
  final readiness = readinessScore(sortedHistory.firstOrNull);
  final acwr = computeAcwr(sortedHistory);

  final dailyBrief = ref
      .read(buildDailyCoachBriefUseCaseProvider)
      .call(
        history: healthHistory,
        recentRuns: recentRuns,
        profile: personalization.profile,
        checkIn: personalization.morningCheckIn,
        acwr: acwr,
      );

  return ref
      .read(buildTodayDirectiveUseCaseProvider)
      .call(
        plan: plan,
        dailyBrief: dailyBrief,
        profile: personalization.profile,
        morningCheckIn: personalization.morningCheckIn,
        todayCheckIn: todayCheckIn,
        readinessScore: readiness > 0 ? readiness : null,
        acwr: acwr,
        now: now,
      );
}

/// Morning accountability + yesterday skip follow-up for the coach empty state.
class CoachAccountabilityState {
  const CoachAccountabilityState({
    required this.morningBriefDue,
    required this.yesterdaySkipped,
  });

  final bool morningBriefDue;
  final bool yesterdaySkipped;

  bool get needsAssertiveNudge => morningBriefDue || yesterdaySkipped;
}

@Riverpod(keepAlive: true)
class CoachAccountability extends _$CoachAccountability {
  static const morningBriefShownDateKey = 'morning_brief_shown_date';

  @override
  CoachAccountabilityState build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final plan = ref.watch(trainingPlanDataProvider).value;
    final now = DateTime.now();
    final todayKey =
        '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
    final shown = prefs.getString(morningBriefShownDateKey);
    return CoachAccountabilityState(
      morningBriefDue: shown != todayKey,
      yesterdaySkipped: _yesterdaySkipped(plan, now),
    );
  }

  Future<void> markMorningBriefShown() async {
    final prefs = ref.read(sharedPreferencesProvider);
    final now = DateTime.now();
    final todayKey =
        '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
    await prefs.setString(morningBriefShownDateKey, todayKey);
    state = CoachAccountabilityState(
      morningBriefDue: false,
      yesterdaySkipped: state.yesterdaySkipped,
    );
  }

  static bool _yesterdaySkipped(TrainingPlan? plan, DateTime now) {
    if (plan == null) return false;
    final yesterday = DateTime(now.year, now.month, now.day)
        .subtract(const Duration(days: 1));
    final day = plan.dayFor(yesterday);
    if (day == null) return false;
    if (day.adherence == PlanAdherenceStatus.skipped) return true;
    if (day.sessionType == PlanSessionType.rest) return false;
    return day.adherence == PlanAdherenceStatus.pending;
  }
}
