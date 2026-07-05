import 'package:flutter/foundation.dart';
import 'package:kynos/domain/entities/dashboard/dashboard_summary.dart';
import 'package:kynos/domain/usecases/insights/today_insights_deterministic.dart';
import 'package:kynos/domain/utils/personal_bests.dart';
import 'package:kynos/domain/utils/run_streak.dart';
import 'package:kynos/domain/utils/weekly_momentum.dart';
import 'package:kynos/features/character/providers/character_provider.dart';
import 'package:kynos/shared/providers/health_providers.dart';
import 'package:kynos/shared/providers/nexus_lab_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dashboard_summary_provider.g.dart';

@riverpod
Future<DashboardSummary> dashboardSummary(Ref ref) async {
  final today = await ref.watch(healthSummaryProvider.future);
  final history = await ref.watch(healthHistoryProvider(days: 30).future);
  final runs = await ref.watch(recentRunsProvider(days: 60, limit: 60).future);
  final character = await ref.watch(runnerCharacterProvider.future);

  final sorted = List.of(history)..sort((a, b) => b.date.compareTo(a.date));
  final history7Day = sorted.take(7).toList();
  final yesterday = today == null
      ? null
      : findYesterdaySummary(history, today.date);

  final streakFromRuns = computeRunStreakFromRuns(runs);
  final streakFromSummaries = computeRunStreakFromSummaries(history);
  final runStreak = streakFromRuns > streakFromSummaries
      ? streakFromRuns
      : streakFromSummaries;

  var isGaitCalibrated = false;
  ({double? b0, double? b1, double? b2}) gaitCoefficients =
      (b0: null, b1: null, b2: null);
  DateTime? gaitCalibratedAt;

  if (!kIsWeb) {
    final lab = await ref.watch(nexusLabProvider.future);
    gaitCoefficients = lab.coefficients;
    gaitCalibratedAt = lab.calibratedAt;
    isGaitCalibrated =
        lab.coefficients.b0 != null &&
        lab.coefficients.b1 != null &&
        lab.coefficients.b2 != null;
  }

  return DashboardSummary(
    runStreak: runStreak,
    weeklyMomentum: computeWeeklyMomentum(history),
    personalBestCallouts: findPersonalBestCallouts(history, today),
    streakNudge: streakAchievementNudge(runStreak),
    character: character,
    yesterday: yesterday,
    history7Day: history7Day,
    isGaitCalibrated: isGaitCalibrated,
    gaitCoefficients: gaitCoefficients,
    gaitCalibratedAt: gaitCalibratedAt,
  );
}
