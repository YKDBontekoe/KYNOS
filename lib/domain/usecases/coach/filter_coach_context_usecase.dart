import 'package:kynos/domain/entities/cloud_data_level.dart';
import 'package:kynos/domain/entities/coach/coach_context.dart';
import 'package:kynos/domain/entities/coach/coach_context_preferences.dart';
import 'package:kynos/domain/entities/coach/coach_data_source.dart';

/// Strips disabled sections from [CoachContext] before prompt formatting.
class FilterCoachContextUseCase {
  const FilterCoachContextUseCase();

  CoachContext call({
    required CoachContext context,
    required CoachContextPreferences preferences,
  }) {
    return CoachContext(
      readinessScore: preferences.isEnabled(CoachDataSource.readinessAcwr)
          ? context.readinessScore
          : 0,
      readinessSummary: preferences.isEnabled(CoachDataSource.readinessAcwr)
          ? context.readinessSummary
          : 'Unavailable',
      acwr: preferences.isEnabled(CoachDataSource.readinessAcwr)
          ? context.acwr
          : null,
      acwrRiskLabel: preferences.isEnabled(CoachDataSource.readinessAcwr)
          ? context.acwrRiskLabel
          : null,
      healthHistory: preferences.isEnabled(CoachDataSource.healthMetrics)
          ? context.healthHistory
          : const [],
      recentRuns: preferences.isEnabled(CoachDataSource.recentRuns)
          ? context.recentRuns
          : const [],
      todayInsights: preferences.isEnabled(CoachDataSource.todayInsights)
          ? context.todayInsights
          : null,
      trainingInsights: preferences.isEnabled(CoachDataSource.trainingInsights)
          ? context.trainingInsights
          : null,
      weeklyMomentum: preferences.isEnabled(CoachDataSource.weeklyMomentum)
          ? context.weeklyMomentum
          : null,
      gaitCoefficients: preferences.isEnabled(CoachDataSource.gaitBiomechanics)
          ? context.gaitCoefficients
          : const (b0: null, b1: null, b2: null),
      isGaitCalibrated: preferences.isEnabled(CoachDataSource.gaitBiomechanics)
          ? context.isGaitCalibrated
          : false,
      seedTopic: context.seedTopic,
      focusRunId: context.focusRunId,
      postRunDebriefSummary:
          preferences.isEnabled(CoachDataSource.postRunDebrief)
          ? context.postRunDebriefSummary
          : null,
      athleteProfile: preferences.isEnabled(CoachDataSource.athletePreferences)
          ? context.athleteProfile
          : null,
      morningCheckIn: context.morningCheckIn,
      dailyBrief: context.dailyBrief,
      dailyHealthBrief: preferences.isEnabled(CoachDataSource.healthMetrics)
          ? context.dailyHealthBrief
          : null,
      healthCheckIns: preferences.isEnabled(CoachDataSource.healthCheckIns)
          ? context.healthCheckIns
          : const [],
      coachMemories: preferences.isEnabled(CoachDataSource.coachMemory)
          ? context.coachMemories
          : const [],
      wellbeingExperiments:
          preferences.isEnabled(CoachDataSource.wellbeingExperiments)
          ? context.wellbeingExperiments
          : const [],
      activePlan: preferences.isEnabled(CoachDataSource.trainingPlan)
          ? context.activePlan
          : null,
      todayDirective: preferences.isEnabled(CoachDataSource.trainingPlan)
          ? context.todayDirective
          : null,
    );
  }

  CloudDataLevel effectiveCloudLevel({
    required CloudDataLevel globalLevel,
    required CoachContextPreferences preferences,
  }) {
    return preferences.cloudLevelOverride ?? globalLevel;
  }
}
