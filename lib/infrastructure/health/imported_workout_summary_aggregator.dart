import 'package:kynos/domain/entities/health_summary.dart';
import 'package:kynos/domain/entities/workout_session.dart';

/// Builds daily [HealthSummary] rollups from imported running workouts.
List<HealthSummary> deriveSummariesFromWorkouts(
  List<WorkoutSession> workouts,
) {
  final byDay = <DateTime, _DayRollup>{};

  for (final workout in workouts) {
    final day = DateTime(
      workout.start.year,
      workout.start.month,
      workout.start.day,
    );
    final rollup = byDay.putIfAbsent(day, () => _DayRollup(date: day));
    rollup.addWorkout(workout);
  }

  return byDay.values
      .map((rollup) => rollup.toSummary())
      .toList()
    ..sort((a, b) => b.date.compareTo(a.date));
}

class _DayRollup {
  _DayRollup({required this.date});

  final DateTime date;
  int runningWorkoutCount = 0;
  double runningWorkoutMinutes = 0;
  double runningWorkoutDistanceMeters = 0;
  double runningWorkoutCalories = 0;

  void addWorkout(WorkoutSession workout) {
    runningWorkoutCount += 1;
    runningWorkoutMinutes += workout.duration.inMinutes.toDouble();
    runningWorkoutDistanceMeters += workout.distanceMeters ?? 0;
    runningWorkoutCalories += workout.energyKcal ?? 0;
  }

  HealthSummary toSummary() {
    return HealthSummary(
      date: date,
      distanceMeters: runningWorkoutDistanceMeters == 0
          ? null
          : runningWorkoutDistanceMeters,
      runningWorkoutCount:
          runningWorkoutCount == 0 ? null : runningWorkoutCount,
      runningWorkoutMinutes:
          runningWorkoutMinutes == 0 ? null : runningWorkoutMinutes,
      runningWorkoutDistanceMeters: runningWorkoutDistanceMeters == 0
          ? null
          : runningWorkoutDistanceMeters,
      runningWorkoutCalories:
          runningWorkoutCalories == 0 ? null : runningWorkoutCalories,
    );
  }
}
