import 'package:kynos/domain/entities/coach/athlete_coach_profile.dart';
import 'package:kynos/domain/entities/coach/training_plan.dart';

/// Builds a deterministic multi-week plan from the athlete profile.
class ProposeTrainingPlanUseCase {
  const ProposeTrainingPlanUseCase();

  TrainingPlan call({
    required AthleteCoachProfile profile,
    DateTime? startDate,
    int weeks = 4,
    double? weeklyVolumeTargetKm,
    int? longRunWeekday,
    String? planId,
  }) {
    final start = _dateOnly(startDate ?? DateTime.now());
    final longDay =
        longRunWeekday ??
        (profile.preferredTrainingDays.contains(DateTime.sunday)
            ? DateTime.sunday
            : (profile.preferredTrainingDays.isNotEmpty
                  ? profile.preferredTrainingDays.last
                  : DateTime.sunday));
    final volume =
        weeklyVolumeTargetKm ??
        _defaultWeeklyVolumeKm(profile.experience, profile.goal);
    final trainingDays = profile.preferredTrainingDays.isNotEmpty
        ? profile.preferredTrainingDays.toSet()
        : <int>{
            DateTime.tuesday,
            DateTime.thursday,
            DateTime.saturday,
            longDay,
          };

    final aligned = <PlanDay>[];
    for (var i = 0; i < weeks * 7; i++) {
      final date = _dateOnly(start.add(Duration(days: i)));
      final weekday = date.weekday;
      final week = i ~/ 7;
      final weekFactor = 1.0 + (week * 0.08);

      if (!trainingDays.contains(weekday)) {
        aligned.add(
          PlanDay(
            date: date,
            sessionType: PlanSessionType.rest,
            title: 'Rest / mobility',
            notes: 'Full rest or 20–30 min easy mobility.',
          ),
        );
        continue;
      }

      if (weekday == longDay) {
        final distance = (volume * 0.35 * weekFactor).clamp(6.0, 32.0);
        aligned.add(
          PlanDay(
            date: date,
            sessionType: PlanSessionType.longRun,
            title: 'Long run',
            targetDistanceKm: double.parse(distance.toStringAsFixed(1)),
            intensityNote: 'Conversational pace; finish strong but controlled.',
          ),
        );
        continue;
      }

      if (weekday == DateTime.tuesday) {
        final distance = (volume * 0.18 * weekFactor).clamp(4.0, 14.0);
        final quality = week.isEven
            ? PlanSessionType.tempo
            : PlanSessionType.intervals;
        aligned.add(
          PlanDay(
            date: date,
            sessionType: quality,
            title: week.isEven ? 'Tempo / threshold' : 'Intervals',
            targetDistanceKm: double.parse(distance.toStringAsFixed(1)),
            intensityNote: week.isEven
                ? 'Comfortably hard; controlled breathing.'
                : 'Quality reps with full recoveries.',
          ),
        );
        continue;
      }

      final easyDistance = (volume * 0.15 * weekFactor).clamp(3.0, 12.0);
      aligned.add(
        PlanDay(
          date: date,
          sessionType: PlanSessionType.easy,
          title: 'Easy run',
          targetDistanceKm: double.parse(easyDistance.toStringAsFixed(1)),
          intensityNote: 'Easy aerobic; nasal breathing should feel available.',
        ),
      );
    }

    final goalLabel = profile.goal.trim().isEmpty
        ? 'general fitness'
        : profile.goal.trim();
    return TrainingPlan(
      id: planId ?? 'plan_${start.millisecondsSinceEpoch}',
      title: '$weeks-week $goalLabel plan',
      goal: goalLabel,
      startDate: start,
      weeks: weeks,
      days: aligned,
      createdAt: DateTime.now(),
      weeklyVolumeTargetKm: volume,
      longRunWeekday: longDay,
      active: true,
    );
  }

  double _defaultWeeklyVolumeKm(String experience, String goal) {
    final base = switch (experience.toLowerCase()) {
      'beginner' => 20.0,
      'advanced' || 'elite' => 55.0,
      _ => 35.0,
    };
    if (goal.toLowerCase().contains('marathon')) return base + 15;
    if (goal.toLowerCase().contains('5k')) return (base - 5).clamp(12.0, 80.0);
    return base;
  }

  DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);
}
