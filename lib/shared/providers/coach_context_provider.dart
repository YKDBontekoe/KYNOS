import 'package:flutter/foundation.dart';
import 'package:kynos/domain/entities/coach/coach_chat_seed.dart';
import 'package:kynos/domain/entities/coach/coach_context.dart';
import 'package:kynos/domain/utils/acwr.dart';
import 'package:kynos/domain/utils/weekly_momentum.dart';
import 'package:kynos/shared/providers/coach_personalization_provider.dart';
import 'package:kynos/shared/providers/coach_usecase_providers.dart';
import 'package:kynos/shared/providers/health_coach_providers.dart';
import 'package:kynos/shared/providers/health_providers.dart';
import 'package:kynos/shared/providers/nexus_lab_provider.dart';
import 'package:kynos/shared/providers/post_run_debrief_provider.dart';
import 'package:kynos/shared/providers/today_insights_provider.dart';
import 'package:kynos/shared/providers/training_insights_provider.dart';
import 'package:kynos/shared/providers/training_plan_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'coach_context_provider.g.dart';

/// Builds unified runner context for coach inference.
@riverpod
Future<CoachContext> coachContext(Ref ref) async {
  return ref.watch(coachContextForConversationProvider(seed: null).future);
}

@riverpod
Future<CoachContext> coachContextForConversation(
  Ref ref, {
  CoachChatSeedData? seed,
}) async {
  final healthHistory = await ref.watch(healthHistoryProvider(days: 28).future);
  final recentRuns = await ref.watch(
    recentRunsProvider(days: 60, limit: 5).future,
  );
  final healthCoachData = await ref.watch(healthCoachDataProvider.future);
  final healthBrief = await ref.watch(dailyHealthBriefProvider.future);
  final activePlan = await ref.watch(trainingPlanDataProvider.future);
  final todayDirective = ref.watch(todayDirectiveProvider);

  final todayInsights = ref.watch(todayInsightsStateProvider).value?.insights;
  final trainingInsights = ref
      .watch(trainingInsightsStateProvider)
      .value
      ?.insights;

  var gaitCoefficients = (
    b0: null as double?,
    b1: null as double?,
    b2: null as double?,
  );
  var isGaitCalibrated = false;
  if (!kIsWeb) {
    final lab = await ref.watch(nexusLabProvider.future);
    gaitCoefficients = lab.coefficients;
    isGaitCalibrated =
        lab.coefficients.b0 != null &&
        lab.coefficients.b1 != null &&
        lab.coefficients.b2 != null;
  }

  final weeklyMomentum = computeWeeklyMomentum(healthHistory);
  final CoachPersonalizationState personalization = ref.watch(
    coachPersonalizationProvider,
  );
  final dailyBrief = ref
      .read(buildDailyCoachBriefUseCaseProvider)
      .call(
        history: healthHistory,
        recentRuns: recentRuns,
        profile: personalization.profile,
        checkIn: personalization.morningCheckIn,
        acwr: computeAcwr(healthHistory),
      );

  String? postRunDebriefSummary;
  final debriefState = ref.watch(postRunDebriefProvider).value;
  if (debriefState != null && debriefState.isRecent) {
    postRunDebriefSummary = debriefState.summaryText;
  }

  return ref
      .read(buildCoachContextUseCaseProvider)
      .call(
        healthHistory: healthHistory,
        recentRuns: recentRuns,
        todayInsights: todayInsights,
        trainingInsights: trainingInsights,
        weeklyMomentum: weeklyMomentum,
        gaitCoefficients: gaitCoefficients,
        isGaitCalibrated: isGaitCalibrated,
        seed: seed,
        postRunDebriefSummary: postRunDebriefSummary,
        athleteProfile: personalization.profile,
        morningCheckIn: personalization.morningCheckIn,
        dailyBrief: dailyBrief,
        dailyHealthBrief: healthBrief,
        healthCheckIns: healthCoachData.checkIns,
        coachMemories: healthCoachData.memories,
        wellbeingExperiments: healthCoachData.experiments,
        activePlan: activePlan,
        todayDirective: todayDirective,
      );
}
