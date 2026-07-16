import 'package:flutter_test/flutter_test.dart';
import 'package:kynos/domain/entities/coach/athlete_coach_profile.dart';
import 'package:kynos/domain/entities/coach/coach_context.dart';
import 'package:kynos/domain/entities/coach/coach_context_preferences.dart';
import 'package:kynos/domain/entities/coach/coach_data_source.dart';
import 'package:kynos/domain/entities/coach/coach_tool_call.dart';
import 'package:kynos/domain/entities/coach/today_directive.dart';
import 'package:kynos/domain/entities/coach/training_plan.dart';
import 'package:kynos/domain/entities/health/health_coach_models.dart';
import 'package:kynos/domain/usecases/coach/coach_tool_plan_queries.dart';

void main() {
  const queries = CoachToolPlanQueries();
  final prefs = CoachContextPreferences(
    enabledSources: CoachDataSource.all,
  );

  TrainingPlan samplePlan() {
    final today = DateTime.now();
    final day = DateTime(today.year, today.month, today.day);
    return TrainingPlan(
      id: 'plan_1',
      title: '4-week 5k plan',
      goal: '5k',
      startDate: day,
      weeks: 4,
      createdAt: day,
      weeklyVolumeTargetKm: 30,
      days: [
        PlanDay(
          date: day,
          sessionType: PlanSessionType.easy,
          title: 'Easy run',
          targetDistanceKm: 5,
        ),
        PlanDay(
          date: day.add(const Duration(days: 1)),
          sessionType: PlanSessionType.rest,
          title: 'Rest',
        ),
      ],
    );
  }

  group('CoachToolPlanQueries', () {
    test('getActiveTrainingPlan summarizes upcoming days', () {
      final plan = samplePlan();
      final result = queries.getActiveTrainingPlan(
        const CoachToolCall(name: 'get_active_training_plan'),
        CoachContext(
          readinessScore: 70,
          readinessSummary: 'Ready',
          activePlan: plan,
          todayDirective: const TodayDirective(
            headline: 'Easy run',
            detail: '5 km',
            source: TodayDirectiveSource.plan,
            rationale: ['plan day'],
          ),
        ),
        prefs,
      );

      expect(result.isError, isFalse);
      expect(result.promptSummary, contains('4-week 5k plan'));
      expect(result.promptSummary, contains('Easy run'));
    });

    test('getActiveTrainingPlan reports missing plan', () {
      final result = queries.getActiveTrainingPlan(
        const CoachToolCall(name: 'get_active_training_plan'),
        const CoachContext(readinessScore: 50, readinessSummary: 'ok'),
        prefs,
      );
      expect(result.isError, isFalse);
      expect(result.promptSummary, contains('No active training plan'));
    });

    test('getTodayDirective returns directive text', () {
      final result = queries.getTodayDirective(
        const CoachToolCall(name: 'get_today_directive'),
        const CoachContext(
          readinessScore: 70,
          readinessSummary: 'Ready',
          todayDirective: TodayDirective(
            headline: 'Tempo',
            detail: '8 km',
            source: TodayDirectiveSource.plan,
            rationale: ['ACWR ok'],
          ),
        ),
        prefs,
      );
      expect(result.isError, isFalse);
      expect(result.promptSummary, contains('Tempo'));
      expect(result.promptSummary, contains('ACWR ok'));
    });

    test('proposeTrainingPlan requires safety acknowledgement', () {
      final result = queries.proposeTrainingPlan(
        const CoachToolCall(name: 'propose_training_plan'),
        const CoachContext(
          readinessScore: 70,
          readinessSummary: 'Ready',
          athleteProfile: AthleteCoachProfile(goal: '5k'),
        ),
      );
      expect(result.isError, isTrue);
    });

    test('proposeTrainingPlan returns pending activation', () {
      final result = queries.proposeTrainingPlan(
        const CoachToolCall(
          name: 'propose_training_plan',
          arguments: {'weeks': 4},
        ),
        const CoachContext(
          readinessScore: 70,
          readinessSummary: 'Ready',
          athleteProfile: AthleteCoachProfile(
            goal: '5k',
            experience: 'intermediate',
            preferredTrainingDays: [
              DateTime.tuesday,
              DateTime.thursday,
              DateTime.sunday,
            ],
            safetyAcknowledged: true,
          ),
        ),
      );
      expect(result.isError, isFalse);
      expect(result.pendingActions, hasLength(1));
      expect(
        result.pendingActions.single.type,
        CoachActionType.activateTrainingPlan,
      );
      expect(result.pendingActions.single.payload['planJson'], isNotNull);
    });

    test('adjustPlanWeek requires an active plan', () {
      final result = queries.adjustPlanWeek(
        const CoachToolCall(
          name: 'adjust_plan_week',
          arguments: {'session_type': 'recovery', 'title': 'Easy jog'},
        ),
        const CoachContext(readinessScore: 60, readinessSummary: 'ok'),
      );
      expect(result.isError, isTrue);
    });

    test('adjustPlanWeek proposes a swap pending action', () {
      final result = queries.adjustPlanWeek(
        const CoachToolCall(
          name: 'adjust_plan_week',
          arguments: {
            'session_type': 'recovery',
            'title': 'Recovery jog',
            'distance_km': 4,
          },
        ),
        CoachContext(
          readinessScore: 60,
          readinessSummary: 'ok',
          activePlan: samplePlan(),
        ),
      );
      expect(result.isError, isFalse);
      expect(result.pendingActions, hasLength(1));
      expect(
        result.pendingActions.single.type,
        CoachActionType.activateTrainingPlan,
      );
    });

    test('respects disabled trainingPlan data source', () {
      final disabled = CoachContextPreferences(
        enabledSources: CoachDataSource.all
            .difference({CoachDataSource.trainingPlan}),
      );
      final result = queries.getActiveTrainingPlan(
        const CoachToolCall(name: 'get_active_training_plan'),
        CoachContext(
          readinessScore: 70,
          readinessSummary: 'Ready',
          activePlan: samplePlan(),
        ),
        disabled,
      );
      expect(result.isError, isTrue);
    });
  });

  group('TrainingPlan serialization', () {
    test('round-trips JSON', () {
      final plan = samplePlan();
      final restored = TrainingPlan.fromJson(plan.toJson());
      expect(restored.id, plan.id);
      expect(restored.days, hasLength(plan.days.length));
      expect(restored.days.first.sessionType, PlanSessionType.easy);
      expect(restored.dayFor(plan.days.first.date)?.title, 'Easy run');
    });
  });
}
