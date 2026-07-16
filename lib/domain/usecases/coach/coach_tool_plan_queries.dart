import 'dart:convert';

import 'package:kynos/domain/entities/coach/coach_context.dart';
import 'package:kynos/domain/entities/coach/coach_context_preferences.dart';
import 'package:kynos/domain/entities/coach/coach_data_source.dart';
import 'package:kynos/domain/entities/coach/coach_tool_call.dart';
import 'package:kynos/domain/entities/coach/training_plan.dart';
import 'package:kynos/domain/entities/health/health_coach_models.dart';
import 'package:kynos/domain/usecases/coach/propose_training_plan_usecase.dart';
import 'package:kynos/domain/utils/coach_tool_result_helpers.dart';

/// Plan/directive tools for the assertive coach agent loop.
class CoachToolPlanQueries {
  const CoachToolPlanQueries();

  CoachToolResult getActiveTrainingPlan(
    CoachToolCall call,
    CoachContext context,
    CoachContextPreferences prefs,
  ) {
    if (!prefs.isEnabled(CoachDataSource.trainingPlan)) {
      return CoachToolResultHelpers.disabled(call, CoachDataSource.trainingPlan);
    }
    final plan = context.activePlan;
    if (plan == null) {
      return CoachToolResult(
        toolCall: call,
        isError: false,
        promptSummary:
            'No active training plan. Propose one with propose_training_plan.',
        displayLabel: 'No active plan',
      );
    }
    final upcoming = plan.days
        .where((day) => !day.dayKey.isBefore(_today()))
        .take(5)
        .map(_describeDay)
        .join('; ');
    return CoachToolResult(
      toolCall: call,
      isError: false,
      promptSummary:
          '${plan.title} · goal ${plan.goal} · ${plan.weeks} weeks · '
          'weekly target ${plan.weeklyVolumeTargetKm?.toStringAsFixed(0) ?? 'n/a'} km. '
          'Upcoming: $upcoming',
      displayLabel: 'Reviewed your training plan',
    );
  }

  CoachToolResult getTodayDirective(
    CoachToolCall call,
    CoachContext context,
    CoachContextPreferences prefs,
  ) {
    if (!prefs.isEnabled(CoachDataSource.trainingPlan)) {
      return CoachToolResultHelpers.disabled(call, CoachDataSource.trainingPlan);
    }
    final directive = context.todayDirective;
    if (directive == null) {
      return CoachToolResultHelpers.error(
        call,
        'Today’s directive is unavailable.',
      );
    }
    return CoachToolResult(
      toolCall: call,
      isError: false,
      promptSummary:
          '${directive.headline}. ${directive.detail} '
          'Source: ${directive.source.name}. '
          'Rationale: ${directive.rationale.join('; ')}',
      displayLabel: 'Resolved today’s directive',
    );
  }

  CoachToolResult proposeTrainingPlan(
    CoachToolCall call,
    CoachContext context,
  ) {
    final profile = context.athleteProfile;
    if (profile == null || !profile.safetyAcknowledged) {
      return CoachToolResultHelpers.error(
        call,
        'Athlete profile with safety acknowledgement is required before proposing a plan.',
      );
    }
    final weeks = CoachToolResultHelpers.intArg(
      call,
      'weeks',
      fallback: 4,
      min: 3,
      max: 8,
    );
    final volumeRaw = CoachToolResultHelpers.rawDoubleArg(
      call,
      'weekly_volume_km',
    );
    final volume = volumeRaw?.clamp(10, 120).toDouble();
    final longRun = CoachToolResultHelpers.intArg(
      call,
      'long_run_weekday',
      fallback: profile.preferredTrainingDays.contains(DateTime.sunday)
          ? DateTime.sunday
          : DateTime.sunday,
      min: 1,
      max: 7,
    );
    final plan = const ProposeTrainingPlanUseCase().call(
      profile: profile,
      weeks: weeks,
      weeklyVolumeTargetKm: volume,
      longRunWeekday: longRun,
    );
    final pending = PendingCoachAction(
      id: plan.id,
      type: CoachActionType.activateTrainingPlan,
      title: 'Activate ${plan.title}?',
      explanation:
          '${plan.weeks} weeks targeting ${plan.goal}. '
          'Weekly volume ~${plan.weeklyVolumeTargetKm?.toStringAsFixed(0)} km. '
          'Confirm to make this the source of truth for daily directives.',
      payload: {'planJson': jsonEncode(plan.toJson())},
    );
    return CoachToolResult(
      toolCall: call,
      isError: false,
      promptSummary:
          'A training-plan proposal is awaiting confirmation: ${plan.title}.',
      displayLabel: 'Prepared a training plan',
      pendingActions: [pending],
    );
  }

  CoachToolResult adjustPlanWeek(
    CoachToolCall call,
    CoachContext context,
  ) {
    final plan = context.activePlan;
    if (plan == null) {
      return CoachToolResultHelpers.error(
        call,
        'No active plan to adjust. Propose a plan first.',
      );
    }
    final typeName =
        CoachToolResultHelpers.stringArg(call, 'session_type')?.trim() ??
        'recovery';
    final sessionType = PlanSessionType.values.firstWhere(
      (value) => value.name == typeName,
      orElse: () => PlanSessionType.recovery,
    );
    final title =
        CoachToolResultHelpers.stringArg(call, 'title')?.trim() ??
        'Adjusted session';
    final distanceRaw = CoachToolResultHelpers.rawDoubleArg(
      call,
      'distance_km',
    );
    final distance = distanceRaw?.clamp(1, 50).toDouble();
    final today = plan.dayFor(DateTime.now()) ??
        PlanDay(
          date: _today(),
          sessionType: sessionType,
          title: title,
        );
    final replacement = today.copyWith(
      sessionType: sessionType,
      title: title,
      targetDistanceKm: distance ?? today.targetDistanceKm,
      adherence: PlanAdherenceStatus.swapped,
      adherenceNote: 'Coach-proposed swap awaiting confirmation',
    );
    final pending = PendingCoachAction(
      id: 'adjust_${DateTime.now().microsecondsSinceEpoch}',
      type: CoachActionType.activateTrainingPlan,
      title: 'Swap today’s session?',
      explanation:
          'Replace today’s ${today.title} with $title'
          '${distance != null ? ' (${distance.toStringAsFixed(1)} km)' : ''}.',
      payload: {
        'planJson': jsonEncode(
          plan
              .copyWith(
                days: [
                  for (final day in plan.days)
                    if (day.dayKey == replacement.dayKey) replacement else day,
                ],
              )
              .toJson(),
        ),
      },
    );
    return CoachToolResult(
      toolCall: call,
      isError: false,
      promptSummary: 'A plan-day swap is awaiting confirmation.',
      displayLabel: 'Prepared a plan adjustment',
      pendingActions: [pending],
    );
  }

  DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  String _describeDay(PlanDay day) {
    final distance = day.targetDistanceKm == null
        ? ''
        : ' ${day.targetDistanceKm!.toStringAsFixed(1)}km';
    return '${day.date.month}/${day.date.day} ${day.title}$distance '
        '(${day.adherence.name})';
  }
}
