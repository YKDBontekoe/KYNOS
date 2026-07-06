import 'package:flutter/foundation.dart';
import 'package:kynos/domain/entities/coach/coach_context.dart';
import 'package:kynos/domain/utils/weekly_momentum.dart';
import 'package:kynos/features/dashboard/providers/post_run_debrief_provider.dart';
import 'package:kynos/features/dashboard/providers/today_insights_provider.dart';
import 'package:kynos/features/training/providers/training_insights_provider.dart';
import 'package:kynos/shared/providers/character_providers.dart';
import 'package:kynos/shared/providers/coach_chat_seed_provider.dart';
import 'package:kynos/shared/providers/coach_usecase_providers.dart';
import 'package:kynos/shared/providers/daily_quests_provider.dart';
import 'package:kynos/shared/providers/health_providers.dart';
import 'package:kynos/shared/providers/nexus_lab_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'coach_context_provider.g.dart';

/// Builds unified runner context for coach inference.
@riverpod
Future<CoachContext> coachContext(Ref ref) async {
  final seed = ref.watch(coachChatSeedProvider);
  final healthHistory =
      await ref.watch(healthHistoryProvider(days: 14).future);
  final recentRuns =
      await ref.watch(recentRunsProvider(days: 60, limit: 5).future);
  final character = await ref.watch(runnerCharacterProvider.future);
  final quests = await ref.watch(dailyQuestsProvider.future);

  final todayInsights = ref.watch(todayInsightsStateProvider).value?.insights;
  final trainingInsights =
      ref.watch(trainingInsightsStateProvider).value?.insights;

  var gaitCoefficients =
      (b0: null as double?, b1: null as double?, b2: null as double?);
  var isGaitCalibrated = false;
  if (!kIsWeb) {
    final lab = await ref.watch(nexusLabProvider.future);
    gaitCoefficients = lab.coefficients;
    isGaitCalibrated = lab.coefficients.b0 != null &&
        lab.coefficients.b1 != null &&
        lab.coefficients.b2 != null;
  }

  final weeklyMomentum = computeWeeklyMomentum(healthHistory);

  String? postRunDebriefSummary;
  final debriefState = ref.watch(postRunDebriefProvider).value;
  if (debriefState != null && debriefState.isRecent) {
    postRunDebriefSummary = debriefState.summaryText;
  }

  return ref.read(buildCoachContextUseCaseProvider).call(
        healthHistory: healthHistory,
        recentRuns: recentRuns,
        character: character,
        activeQuests: quests,
        todayInsights: todayInsights,
        trainingInsights: trainingInsights,
        weeklyMomentum: weeklyMomentum,
        gaitCoefficients: gaitCoefficients,
        isGaitCalibrated: isGaitCalibrated,
        seed: seed,
        postRunDebriefSummary: postRunDebriefSummary,
      );
}
