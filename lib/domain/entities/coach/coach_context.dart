import 'package:kynos/domain/entities/coach/coach_seed_topic.dart';
import 'package:kynos/domain/entities/gamification/quest.dart';
import 'package:kynos/domain/entities/gamification/runner_character.dart';
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
    this.character,
    this.activeQuests = const [],
    this.weeklyMomentum,
    this.gaitCoefficients = const (b0: null, b1: null, b2: null),
    this.isGaitCalibrated = false,
    this.seedTopic = CoachSeedTopic.general,
    this.focusRunId,
    this.focusQuestId,
    this.postRunDebriefSummary,
  });

  final double readinessScore;
  final String readinessSummary;
  final double? acwr;
  final String? acwrRiskLabel;
  final List<HealthSummary> healthHistory;
  final List<WorkoutSession> recentRuns;
  final TodayInsights? todayInsights;
  final TrainingInsights? trainingInsights;
  final RunnerCharacter? character;
  final List<Quest> activeQuests;
  final WeeklyMomentum? weeklyMomentum;
  final ({double? b0, double? b1, double? b2}) gaitCoefficients;
  final bool isGaitCalibrated;
  final CoachSeedTopic seedTopic;
  final String? focusRunId;
  final String? focusQuestId;
  final String? postRunDebriefSummary;

  /// Short badge line for the coach app bar.
  String get contextBadge {
    final parts = <String>[
      'Readiness ${readinessScore.round()}',
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
