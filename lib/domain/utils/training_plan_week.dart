import 'package:kynos/domain/entities/coach/training_plan.dart';

/// Monday-start calendar day for [date] (time stripped).
DateTime planDayKey(DateTime date) =>
    DateTime(date.year, date.month, date.day);

/// Monday of the week containing [date] (ISO weekday: Mon=1).
DateTime planWeekStart(DateTime date) {
  final key = planDayKey(date);
  return key.subtract(Duration(days: key.weekday - DateTime.monday));
}

/// The seven calendar days (Mon–Sun) for the week containing [date].
List<DateTime> planWeekDates(DateTime date) {
  final start = planWeekStart(date);
  return [for (var i = 0; i < 7; i++) start.add(Duration(days: i))];
}

/// Plan days for the week containing [date], aligned Mon–Sun (null = no entry).
List<PlanDay?> planWeekSlots(TrainingPlan plan, DateTime date) {
  return [for (final day in planWeekDates(date)) plan.dayFor(day)];
}

/// Non-rest days in the week containing [date].
List<PlanDay> planWeekTrainingDays(TrainingPlan plan, DateTime date) {
  return planWeekSlots(plan, date)
      .whereType<PlanDay>()
      .where((day) => day.sessionType != PlanSessionType.rest)
      .toList(growable: false);
}

/// Adherence counts for the week containing [date] (non-rest only).
({int done, int skipped, int pending, int swapped}) planWeekAdherenceCounts(
  TrainingPlan plan,
  DateTime date,
) {
  var done = 0;
  var skipped = 0;
  var pending = 0;
  var swapped = 0;
  for (final day in planWeekTrainingDays(plan, date)) {
    switch (day.adherence) {
      case PlanAdherenceStatus.done:
        done++;
      case PlanAdherenceStatus.skipped:
        skipped++;
      case PlanAdherenceStatus.pending:
        pending++;
      case PlanAdherenceStatus.swapped:
        swapped++;
    }
  }
  return (done: done, skipped: skipped, pending: pending, swapped: swapped);
}
