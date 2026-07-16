import 'package:kynos/domain/entities/coach/training_plan.dart';
import 'package:kynos/domain/entities/workout_session.dart';
import 'package:kynos/domain/utils/training_plan_week.dart';

/// A workout that confidently matches a pending plan day.
class PlanWorkoutMatch {
  const PlanWorkoutMatch({
    required this.day,
    required this.workout,
    required this.confidence,
    required this.note,
  });

  final PlanDay day;
  final WorkoutSession workout;
  final double confidence;
  final String note;
}

/// Deterministically matches synced workouts to pending plan days.
///
/// Matching prefers same calendar day, then distance/duration proximity.
/// Rest days are never auto-marked done.
class MatchWorkoutToPlanDayUseCase {
  const MatchWorkoutToPlanDayUseCase();

  /// Minimum confidence to auto-mark adherence without asking the user.
  static const autoMarkThreshold = 0.55;

  List<PlanWorkoutMatch> call({
    required TrainingPlan plan,
    required List<WorkoutSession> workouts,
    DateTime? now,
  }) {
    final reference = now ?? DateTime.now();
    final pendingDays = plan.days.where((day) {
      if (day.sessionType == PlanSessionType.rest) return false;
      if (day.adherence != PlanAdherenceStatus.pending) return false;
      // Only auto-match recent / current window (last 14 days through tomorrow).
      final age = planDayKey(reference).difference(day.dayKey).inDays;
      return age >= -1 && age <= 14;
    }).toList(growable: false);

    if (pendingDays.isEmpty || workouts.isEmpty) return const [];

    final usedWorkoutIds = <String>{};
    final matches = <PlanWorkoutMatch>[];

    for (final day in pendingDays) {
      PlanWorkoutMatch? best;
      for (final workout in workouts) {
        if (usedWorkoutIds.contains(workout.id)) continue;
        final scored = _score(day, workout);
        if (scored == null) continue;
        if (best == null || scored.confidence > best.confidence) {
          best = scored;
        }
      }
      if (best == null || best.confidence < autoMarkThreshold) continue;
      usedWorkoutIds.add(best.workout.id);
      matches.add(best);
    }

    return matches;
  }

  PlanWorkoutMatch? _score(PlanDay day, WorkoutSession workout) {
    final workoutDay = planDayKey(workout.end);
    if (workoutDay != day.dayKey) return null;

    final distanceKm = (workout.distanceMeters ?? 0) / 1000;
    final durationMin = workout.duration.inMinutes;
    if (distanceKm <= 0 && durationMin <= 0) return null;

    var confidence = 0.6; // same-day workout alone is a decent signal
    final notes = <String>['Matched ${workout.workoutType} on ${day.title}'];

    final targetKm = day.targetDistanceKm;
    if (targetKm != null && targetKm > 0 && distanceKm > 0) {
      final ratio = distanceKm / targetKm;
      final distanceScore = ratio >= 0.7 && ratio <= 1.35
          ? 0.35
          : ratio >= 0.5 && ratio <= 1.6
          ? 0.15
          : 0.0;
      confidence += distanceScore;
      notes.add('${distanceKm.toStringAsFixed(1)} km vs ${targetKm.toStringAsFixed(1)} km target');
    } else if (distanceKm > 0) {
      confidence += 0.15;
      notes.add('${distanceKm.toStringAsFixed(1)} km logged');
    }

    final targetMin = day.targetDurationMinutes;
    if (targetMin != null && targetMin > 0 && durationMin > 0) {
      final ratio = durationMin / targetMin;
      final durationScore = ratio >= 0.7 && ratio <= 1.35
          ? 0.2
          : ratio >= 0.5 && ratio <= 1.6
          ? 0.1
          : 0.0;
      confidence += durationScore;
    }

    return PlanWorkoutMatch(
      day: day,
      workout: workout,
      confidence: confidence.clamp(0.0, 1.0),
      note: notes.join(' · '),
    );
  }
}
