import 'package:flutter_test/flutter_test.dart';
import 'package:kynos/domain/entities/coach/athlete_coach_profile.dart';
import 'package:kynos/domain/entities/coach/daily_coach_brief.dart';
import 'package:kynos/domain/entities/coach/today_directive.dart';
import 'package:kynos/domain/entities/coach/training_plan.dart';
import 'package:kynos/domain/usecases/coach/build_today_directive_usecase.dart';
import 'package:kynos/domain/usecases/coach/log_plan_adherence_usecase.dart';
import 'package:kynos/domain/usecases/coach/propose_training_plan_usecase.dart';

void main() {
  group('ProposeTrainingPlanUseCase', () {
    test('builds aligned multi-week days from profile', () {
      const useCase = ProposeTrainingPlanUseCase();
      final plan = useCase.call(
        profile: const AthleteCoachProfile(
          goal: 'half marathon',
          experience: 'intermediate',
          preferredTrainingDays: [
            DateTime.tuesday,
            DateTime.thursday,
            DateTime.saturday,
            DateTime.sunday,
          ],
          safetyAcknowledged: true,
        ),
        startDate: DateTime(2026, 7, 13), // Monday
        weeks: 4,
      );

      expect(plan.weeks, 4);
      expect(plan.days, hasLength(28));
      expect(plan.goal, 'half marathon');
      expect(
        plan.days.where((day) => day.sessionType == PlanSessionType.longRun),
        isNotEmpty,
      );
      expect(
        plan.days.where((day) => day.sessionType == PlanSessionType.rest),
        isNotEmpty,
      );
    });
  });

  group('BuildTodayDirectiveUseCase', () {
    test('returns build-plan CTA when no plan exists', () {
      const useCase = BuildTodayDirectiveUseCase();
      final directive = useCase.call(
        profile: const AthleteCoachProfile(goal: '5k'),
        dailyBrief: const DailyCoachBrief(
          recommendation: 'normal training is reasonable',
          confidence: 'medium',
          evidence: ['sleep 7.5h'],
          dataQuality: 'partial',
        ),
      );

      expect(directive.source, TodayDirectiveSource.buildPlanCta);
      expect(directive.ctaLabel, 'Build my plan');
    });

    test('prescribes plan day and can force recovery', () {
      const useCase = BuildTodayDirectiveUseCase();
      final today = DateTime(2026, 7, 14);
      final plan = TrainingPlan(
        id: 'p1',
        title: 'Test plan',
        goal: '5k',
        startDate: today,
        weeks: 1,
        createdAt: today,
        days: [
          PlanDay(
            date: today,
            sessionType: PlanSessionType.tempo,
            title: 'Tempo',
            targetDistanceKm: 8,
          ),
        ],
      );

      final directive = useCase.call(
        plan: plan,
        now: today,
        readinessScore: 30,
        dailyBrief: const DailyCoachBrief(
          recommendation: 'recovery-biased: easy movement or rest',
          confidence: 'high',
          evidence: ['HRV low'],
          dataQuality: 'good',
        ),
      );

      expect(directive.forcedRecovery, isTrue);
      expect(directive.sessionType, PlanSessionType.recovery);
    });
  });

  group('LogPlanAdherenceUseCase', () {
    test('marks a day done', () {
      const useCase = LogPlanAdherenceUseCase();
      final today = DateTime(2026, 7, 14);
      final plan = TrainingPlan(
        id: 'p1',
        title: 'Test plan',
        goal: '5k',
        startDate: today,
        weeks: 1,
        createdAt: today,
        days: [
          PlanDay(
            date: today,
            sessionType: PlanSessionType.easy,
            title: 'Easy',
          ),
        ],
      );

      final updated = useCase.call(
        plan: plan,
        date: today,
        status: PlanAdherenceStatus.done,
      );

      expect(updated.days.single.adherence, PlanAdherenceStatus.done);
    });
  });
}
