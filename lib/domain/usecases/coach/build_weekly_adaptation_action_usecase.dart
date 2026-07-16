import 'dart:convert';

import 'package:kynos/domain/entities/coach/training_plan.dart';
import 'package:kynos/domain/entities/health/health_coach_models.dart';
import 'package:kynos/domain/utils/training_plan_week.dart';

/// Builds a confirmable weekly plan adaptation when the week needs protecting.
class BuildWeeklyAdaptationActionUseCase {
  const BuildWeeklyAdaptationActionUseCase();

  /// Returns a pending activate/swap action, or null when no nudge is needed.
  PendingCoachAction? call({
    required TrainingPlan plan,
    DateTime? now,
    double? readinessScore,
    double? acwr,
    String? alreadyNudgedWeekKey,
  }) {
    final reference = now ?? DateTime.now();
    final weekKey = _weekKey(reference);
    if (alreadyNudgedWeekKey == weekKey) return null;

    final counts = planWeekAdherenceCounts(plan, reference);
    final trainingDays = planWeekTrainingDays(plan, reference);
    if (trainingDays.isEmpty) return null;

    final weekday = planDayKey(reference).weekday;
    final endOfWeek = weekday >= DateTime.friday;
    final manySkipped = counts.skipped >= 2;
    final enoughLogged = counts.done + counts.skipped >= 3;
    final lowReadiness = readinessScore != null && readinessScore < 45;
    final elevatedLoad = acwr != null && acwr > 1.3;

    final shouldNudge = manySkipped ||
        (endOfWeek && counts.pending > 0) ||
        (enoughLogged && (lowReadiness || elevatedLoad) && counts.pending > 0);
    if (!shouldNudge) return null;

    final target = _nextHardPendingDay(plan, reference);
    if (target == null) return null;

    final replacement = target.copyWith(
      sessionType: PlanSessionType.recovery,
      title: 'Protected recovery',
      targetDistanceKm: target.targetDistanceKm == null
          ? null
          : (target.targetDistanceKm! * 0.6).clamp(3, 12),
      intensityNote: 'Weekly adaptation — protect the week',
      adherence: PlanAdherenceStatus.swapped,
      adherenceNote: 'Weekly adaptation awaiting confirmation',
    );

    final updated = plan.copyWith(
      days: [
        for (final day in plan.days)
          if (day.dayKey == replacement.dayKey) replacement else day,
      ],
    );

    final reasons = <String>[
      if (manySkipped) '${counts.skipped} sessions skipped',
      if (counts.done > 0) '${counts.done} completed',
      if (lowReadiness) 'readiness soft',
      if (elevatedLoad) 'load elevated',
      if (endOfWeek) 'end of week',
    ];

    return PendingCoachAction(
      id: 'weekly_adapt_$weekKey',
      type: CoachActionType.activateTrainingPlan,
      title: 'Protect the week?',
      explanation:
          'Swap ${target.title} (${_shortDate(target.date)}) for recovery. '
          '${reasons.take(3).join(' · ')}.',
      payload: {
        'planJson': jsonEncode(updated.toJson()),
        'weekKey': weekKey,
        'adaptedDay': target.dayKey.toIso8601String(),
      },
    );
  }

  PlanDay? _nextHardPendingDay(TrainingPlan plan, DateTime reference) {
    final today = planDayKey(reference);
    final hardTypes = {
      PlanSessionType.tempo,
      PlanSessionType.intervals,
      PlanSessionType.longRun,
      PlanSessionType.race,
    };
    PlanDay? fallback;
    for (final day in planWeekSlots(plan, reference).whereType<PlanDay>()) {
      if (day.dayKey.isBefore(today)) continue;
      if (day.adherence != PlanAdherenceStatus.pending) continue;
      if (day.sessionType == PlanSessionType.rest) continue;
      if (hardTypes.contains(day.sessionType)) return day;
      fallback ??= day;
    }
    return fallback;
  }

  String _weekKey(DateTime date) {
    final start = planWeekStart(date);
    return '${start.year.toString().padLeft(4, '0')}-'
        '${start.month.toString().padLeft(2, '0')}-'
        '${start.day.toString().padLeft(2, '0')}';
  }

  String _shortDate(DateTime date) => '${date.month}/${date.day}';
}
