import 'package:flutter_test/flutter_test.dart';
import 'package:kynos/domain/entities/coach/training_plan.dart';
import 'package:kynos/domain/entities/workout_session.dart';
import 'package:kynos/domain/usecases/coach/build_weekly_adaptation_action_usecase.dart';
import 'package:kynos/domain/usecases/coach/match_workout_to_plan_day_usecase.dart';
import 'package:kynos/domain/utils/training_plan_week.dart';

TrainingPlan _samplePlan({
  required DateTime monday,
  PlanAdherenceStatus mondayStatus = PlanAdherenceStatus.pending,
  PlanAdherenceStatus wednesdayStatus = PlanAdherenceStatus.pending,
  PlanSessionType wednesdayType = PlanSessionType.tempo,
}) {
  return TrainingPlan(
    id: 'plan1',
    title: 'Base plan',
    goal: '5k',
    startDate: monday,
    weeks: 1,
    createdAt: monday,
    days: [
      PlanDay(
        date: monday,
        sessionType: PlanSessionType.easy,
        title: 'Easy run',
        targetDistanceKm: 6,
        adherence: mondayStatus,
      ),
      PlanDay(
        date: monday.add(const Duration(days: 1)),
        sessionType: PlanSessionType.rest,
        title: 'Rest',
      ),
      PlanDay(
        date: monday.add(const Duration(days: 2)),
        sessionType: wednesdayType,
        title: 'Tempo',
        targetDistanceKm: 8,
        adherence: wednesdayStatus,
      ),
      PlanDay(
        date: monday.add(const Duration(days: 3)),
        sessionType: PlanSessionType.easy,
        title: 'Easy',
        targetDistanceKm: 5,
      ),
      PlanDay(
        date: monday.add(const Duration(days: 4)),
        sessionType: PlanSessionType.intervals,
        title: 'Intervals',
        targetDistanceKm: 7,
      ),
      PlanDay(
        date: monday.add(const Duration(days: 5)),
        sessionType: PlanSessionType.rest,
        title: 'Rest',
      ),
      PlanDay(
        date: monday.add(const Duration(days: 6)),
        sessionType: PlanSessionType.longRun,
        title: 'Long run',
        targetDistanceKm: 14,
      ),
    ],
  );
}

void main() {
  final monday = DateTime(2026, 7, 13); // Monday

  group('training_plan_week helpers', () {
    test('planWeekStart returns Monday', () {
      expect(planWeekStart(DateTime(2026, 7, 16)), DateTime(2026, 7, 13));
    });

    test('planWeekAdherenceCounts ignores rest days', () {
      final plan = _samplePlan(
        monday: monday,
        mondayStatus: PlanAdherenceStatus.done,
        wednesdayStatus: PlanAdherenceStatus.skipped,
      );
      final counts = planWeekAdherenceCounts(plan, DateTime(2026, 7, 16));
      expect(counts.done, 1);
      expect(counts.skipped, 1);
      expect(counts.pending, 3); // Thu easy, Fri intervals, Sun long
    });
  });

  group('MatchWorkoutToPlanDayUseCase', () {
    const useCase = MatchWorkoutToPlanDayUseCase();

    test('matches same-day workout near target distance', () {
      final plan = _samplePlan(monday: monday);
      final workout = WorkoutSession(
        id: 'w1',
        start: monday.add(const Duration(hours: 7)),
        end: monday.add(const Duration(hours: 8)),
        workoutType: 'Running',
        distanceMeters: 5800,
        sourceName: 'test',
      );

      final matches = useCase(
        plan: plan,
        workouts: [workout],
        now: monday.add(const Duration(hours: 10)),
      );

      expect(matches, hasLength(1));
      expect(matches.first.day.title, 'Easy run');
      expect(matches.first.confidence, greaterThanOrEqualTo(0.55));
    });

    test('does not match rest days or already-done days', () {
      final plan = _samplePlan(
        monday: monday,
        mondayStatus: PlanAdherenceStatus.done,
      );
      final restDay = monday.add(const Duration(days: 1));
      final workout = WorkoutSession(
        id: 'w2',
        start: restDay.add(const Duration(hours: 7)),
        end: restDay.add(const Duration(hours: 8)),
        workoutType: 'Running',
        distanceMeters: 5000,
        sourceName: 'test',
      );

      final matches = useCase(
        plan: plan,
        workouts: [workout],
        now: restDay.add(const Duration(hours: 10)),
      );
      expect(matches, isEmpty);
    });
  });

  group('BuildWeeklyAdaptationActionUseCase', () {
    const useCase = BuildWeeklyAdaptationActionUseCase();

    test('nudges recovery swap when skips pile up', () {
      final plan = _samplePlan(
        monday: monday,
        mondayStatus: PlanAdherenceStatus.skipped,
        wednesdayStatus: PlanAdherenceStatus.skipped,
      );
      final action = useCase(
        plan: plan,
        now: DateTime(2026, 7, 16), // Thursday
      );

      expect(action, isNotNull);
      expect(action!.title, contains('Protect'));
      expect(action.payload['weekKey'], '2026-07-13');
      expect(action.payload['planJson'], isNotNull);
    });

    test('returns null when week already dismissed', () {
      final plan = _samplePlan(
        monday: monday,
        mondayStatus: PlanAdherenceStatus.skipped,
        wednesdayStatus: PlanAdherenceStatus.skipped,
      );
      final action = useCase(
        plan: plan,
        now: DateTime(2026, 7, 16),
        alreadyNudgedWeekKey: '2026-07-13',
      );
      expect(action, isNull);
    });

    test('nudges at end of week with pending sessions', () {
      final plan = _samplePlan(monday: monday);
      final action = useCase(
        plan: plan,
        now: DateTime(2026, 7, 18), // Saturday
      );
      expect(action, isNotNull);
    });
  });
}
