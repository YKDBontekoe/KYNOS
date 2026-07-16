import 'package:kynos/domain/entities/coach/athlete_coach_profile.dart';
import 'package:kynos/domain/entities/coach/coach_seed_topic.dart';
import 'package:kynos/domain/entities/coach/daily_coach_brief.dart';
import 'package:kynos/domain/entities/coach/morning_check_in.dart';
import 'package:kynos/domain/entities/coach/today_directive.dart';
import 'package:kynos/domain/entities/coach/training_plan.dart';
import 'package:kynos/domain/entities/health/health_coach_models.dart';
import 'package:kynos/domain/entities/health_summary.dart';
import 'package:kynos/domain/entities/insights/today_insights.dart';
import 'package:kynos/domain/entities/insights/training_insights.dart';
import 'package:kynos/domain/entities/workout_session.dart';
import 'package:kynos/domain/utils/weekly_momentum.dart';

/// Aggregated runner context injected into coach prompts.
class CoachContext {
  const CoachContext({
    required this.readinessScore,
    required this.readinessSummary,
    this.acwr,
    this.acwrRiskLabel,
    this.healthHistory = const [],
    this.recentRuns = const [],
    this.todayInsights,
    this.trainingInsights,
    this.weeklyMomentum,
    this.gaitCoefficients = const (b0: null, b1: null, b2: null),
    this.isGaitCalibrated = false,
    this.seedTopic = CoachSeedTopic.general,
    this.focusRunId,
    this.postRunDebriefSummary,
    this.athleteProfile,
    this.morningCheckIn,
    this.dailyBrief,
    this.dailyHealthBrief,
    this.healthCheckIns = const [],
    this.coachMemories = const [],
    this.wellbeingExperiments = const [],
    this.activePlan,
    this.todayDirective,
  });

  final double readinessScore;
  final String readinessSummary;
  final double? acwr;
  final String? acwrRiskLabel;
  final List<HealthSummary> healthHistory;
  final List<WorkoutSession> recentRuns;
  final TodayInsights? todayInsights;
  final TrainingInsights? trainingInsights;
  final WeeklyMomentum? weeklyMomentum;
  final ({double? b0, double? b1, double? b2}) gaitCoefficients;
  final bool isGaitCalibrated;
  final CoachSeedTopic seedTopic;
  final String? focusRunId;
  final String? postRunDebriefSummary;
  final AthleteCoachProfile? athleteProfile;
  final MorningCheckIn? morningCheckIn;
  final DailyCoachBrief? dailyBrief;
  final DailyHealthBrief? dailyHealthBrief;
  final List<HealthCheckIn> healthCheckIns;
  final List<CoachMemory> coachMemories;
  final List<WellbeingExperiment> wellbeingExperiments;
  final TrainingPlan? activePlan;
  final TodayDirective? todayDirective;

  /// Short badge line for the coach app bar.
  String get contextBadge {
    final parts = <String>[
      dailyHealthBrief?.baselineQuality == BaselineQuality.stable
          ? 'Personal baseline ready'
          : 'Learning your baseline',
    ];
    if (acwr != null) {
      parts.add('ACWR ${acwr!.toStringAsFixed(2)}');
    }
    if (recentRuns.isNotEmpty) {
      parts.add('${recentRuns.length} recent runs');
    }
    return parts.join(' · ');
  }
}
