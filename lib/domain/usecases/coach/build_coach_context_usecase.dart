import 'package:kynos/domain/entities/coach/athlete_coach_profile.dart';
import 'package:kynos/domain/entities/coach/coach_chat_seed.dart';
import 'package:kynos/domain/entities/coach/coach_context.dart';
import 'package:kynos/domain/entities/coach/daily_coach_brief.dart';
import 'package:kynos/domain/entities/coach/morning_check_in.dart';
import 'package:kynos/domain/entities/health/health_coach_models.dart';
import 'package:kynos/domain/entities/health_summary.dart';
import 'package:kynos/domain/entities/insights/today_insights.dart';
import 'package:kynos/domain/entities/insights/training_insights.dart';
import 'package:kynos/domain/entities/workout_session.dart';
import 'package:kynos/domain/utils/acwr.dart';
import 'package:kynos/domain/utils/readiness_score.dart';
import 'package:kynos/domain/utils/weekly_momentum.dart';

/// Builds [CoachContext] from pre-fetched app data (pure domain, no Riverpod).
class BuildCoachContextUseCase {
  const BuildCoachContextUseCase();

  CoachContext call({
    required List<HealthSummary> healthHistory,
    required List<WorkoutSession> recentRuns,
    TodayInsights? todayInsights,
    TrainingInsights? trainingInsights,
    WeeklyMomentum? weeklyMomentum,
    ({double? b0, double? b1, double? b2}) gaitCoefficients = const (
      b0: null,
      b1: null,
      b2: null,
    ),
    bool isGaitCalibrated = false,
    CoachChatSeedData? seed,
    String? postRunDebriefSummary,
    AthleteCoachProfile? athleteProfile,
    MorningCheckIn? morningCheckIn,
    DailyCoachBrief? dailyBrief,
    DailyHealthBrief? dailyHealthBrief,
    List<HealthCheckIn> healthCheckIns = const [],
    List<CoachMemory> coachMemories = const [],
    List<WellbeingExperiment> wellbeingExperiments = const [],
  }) {
    final sortedHistory = List<HealthSummary>.from(healthHistory)
      ..sort((a, b) => b.date.compareTo(a.date));
    final today = sortedHistory.isNotEmpty ? sortedHistory.first : null;
    final score = readinessScore(today);
    final acwrValue = computeAcwr(sortedHistory);

    var runs = List<WorkoutSession>.from(recentRuns)
      ..sort((a, b) => b.start.compareTo(a.start));

    final seedData = seed ?? const CoachChatSeedData();
    if (seedData.runId != null) {
      final focus = runs.where((r) => r.id == seedData.runId).firstOrNull;
      if (focus != null) {
        runs = [focus, ...runs.where((r) => r.id != focus.id)];
      }
    }

    return CoachContext(
      readinessScore: score,
      readinessSummary: readinessSummary(score),
      acwr: acwrValue,
      acwrRiskLabel: acwrValue != null ? acwrRiskLabel(acwrValue) : null,
      healthHistory: sortedHistory.take(14).toList(),
      recentRuns: runs.take(5).toList(),
      todayInsights: todayInsights,
      trainingInsights: trainingInsights,
      weeklyMomentum: weeklyMomentum,
      gaitCoefficients: gaitCoefficients,
      isGaitCalibrated: isGaitCalibrated,
      seedTopic: seedData.topic,
      focusRunId: seedData.runId,
      postRunDebriefSummary: postRunDebriefSummary,
      athleteProfile: athleteProfile,
      morningCheckIn: morningCheckIn,
      dailyBrief: dailyBrief,
      dailyHealthBrief: dailyHealthBrief,
      healthCheckIns: healthCheckIns,
      coachMemories: coachMemories,
      wellbeingExperiments: wellbeingExperiments,
    );
  }
}
