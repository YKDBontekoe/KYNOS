import 'package:kynos/domain/entities/gamification/quest.dart';
import 'package:kynos/domain/entities/health_summary.dart';
import 'package:kynos/domain/entities/workout_session.dart';

class EvaluateQuestProgressUseCase {
  const EvaluateQuestProgressUseCase();

  double progress({
    required Quest quest,
    HealthSummary? summary,
    List<WorkoutSession> todayRuns = const [],
  }) {
    final objective = quest.measurableObjective;
    if (objective == null || !objective.isMeasurable) return 0;

    return switch (objective.kind) {
      QuestObjectiveKind.steps =>
        (summary?.steps ?? 0).toDouble(),
      QuestObjectiveKind.activeCalories =>
        summary?.activeCalories ?? 0,
      QuestObjectiveKind.runMinutes => todayRuns.fold<double>(
          0,
          (sum, run) => sum + run.duration.inMinutes,
        ),
      QuestObjectiveKind.runDistanceKm => todayRuns.fold<double>(
          0,
          (sum, run) => sum + (run.distanceMeters ?? 0) / 1000,
        ),
      QuestObjectiveKind.manual => 0,
    };
  }

  bool isComplete({
    required Quest quest,
    HealthSummary? summary,
    List<WorkoutSession> todayRuns = const [],
  }) {
    final objective = quest.measurableObjective;
    if (objective == null || !objective.isMeasurable) return false;
    return progress(
          quest: quest,
          summary: summary,
          todayRuns: todayRuns,
        ) >=
        objective.target;
  }

  double progressFraction({
    required Quest quest,
    HealthSummary? summary,
    List<WorkoutSession> todayRuns = const [],
  }) {
    final objective = quest.measurableObjective;
    if (objective == null || !objective.isMeasurable || objective.target <= 0) {
      return 0;
    }
    return (progress(
              quest: quest,
              summary: summary,
              todayRuns: todayRuns,
            ) /
            objective.target)
        .clamp(0.0, 1.0);
  }
}
