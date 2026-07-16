import 'package:kynos/domain/entities/coach/training_plan.dart';

/// Updates adherence for a single plan day.
class LogPlanAdherenceUseCase {
  const LogPlanAdherenceUseCase();

  TrainingPlan call({
    required TrainingPlan plan,
    required DateTime date,
    required PlanAdherenceStatus status,
    String? note,
    PlanDay? replacementDay,
  }) {
    final key = DateTime(date.year, date.month, date.day);
    final days = plan.days.map((day) {
      if (day.dayKey != key) return day;
      if (replacementDay != null) {
        return replacementDay.copyWith(
          date: day.date,
          adherence: status,
          adherenceNote: note,
        );
      }
      return day.copyWith(adherence: status, adherenceNote: note);
    }).toList(growable: false);
    return plan.copyWith(days: days);
  }
}
