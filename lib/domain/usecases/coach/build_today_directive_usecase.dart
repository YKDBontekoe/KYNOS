import 'package:kynos/domain/entities/coach/athlete_coach_profile.dart';
import 'package:kynos/domain/entities/coach/daily_coach_brief.dart';
import 'package:kynos/domain/entities/coach/morning_check_in.dart';
import 'package:kynos/domain/entities/coach/today_directive.dart';
import 'package:kynos/domain/entities/coach/training_plan.dart';
import 'package:kynos/domain/entities/health/health_coach_models.dart';
import 'package:kynos/domain/utils/health_safety_policy.dart';

/// Resolves a deterministic “do this today” directive from plan + readiness.
class BuildTodayDirectiveUseCase {
  const BuildTodayDirectiveUseCase();

  TodayDirective call({
    TrainingPlan? plan,
    DailyCoachBrief? dailyBrief,
    AthleteCoachProfile? profile,
    MorningCheckIn? morningCheckIn,
    HealthCheckIn? todayCheckIn,
    double? readinessScore,
    double? acwr,
    DateTime? now,
  }) {
    final today = now ?? DateTime.now();
    final rationale = <String>[];

    final urgentNote = todayCheckIn?.note;
    if (urgentNote != null && HealthSafetyPolicy.hasUrgentText(urgentNote)) {
      return TodayDirective(
        headline: 'Stop and seek medical care if needed',
        detail:
            'Your check-in note looks urgent. Do not train. Follow medical guidance.',
        source: TodayDirectiveSource.readinessFallback,
        rationale: const ['Urgent symptom language in today’s check-in'],
        sessionType: PlanSessionType.rest,
        forcedRecovery: true,
        adherence: PlanAdherenceStatus.pending,
      );
    }

    final recoveryForced = _shouldForceRecovery(
      dailyBrief: dailyBrief,
      morningCheckIn: morningCheckIn,
      todayCheckIn: todayCheckIn,
      readinessScore: readinessScore,
      acwr: acwr,
      rationale: rationale,
    );

    final planDay = plan?.dayFor(today);
    if (plan == null || planDay == null) {
      final goal = profile?.goal.trim();
      return TodayDirective(
        headline: goal == null || goal.isEmpty
            ? 'Build your training plan'
            : 'Build your plan for $goal',
        detail: recoveryForced
            ? 'Recovery signals are elevated today. After you confirm a plan, '
                'today will default to easy recovery until load settles.'
            : 'Set a multi-week plan so every open lands on a clear session — '
                'not a vague suggestion.',
        source: TodayDirectiveSource.buildPlanCta,
        rationale: [
          if (dailyBrief != null) dailyBrief.recommendation,
          ...rationale,
        ].where((item) => item.trim().isNotEmpty).take(3).toList(),
        ctaLabel: 'Build my plan',
        forcedRecovery: recoveryForced,
      );
    }

    if (recoveryForced &&
        planDay.sessionType != PlanSessionType.rest &&
        planDay.sessionType != PlanSessionType.recovery) {
      rationale.add('Plan session overridden: ${planDay.title}');
      return TodayDirective(
        headline: 'Recovery day (plan override)',
        detail:
            'Signals say back off. Swap today’s ${planDay.title.toLowerCase()} '
            'for easy movement or full rest. We will protect the week.',
        source: TodayDirectiveSource.plan,
        rationale: rationale.take(4).toList(),
        sessionType: PlanSessionType.recovery,
        targetDurationMinutes: 30,
        adherence: planDay.adherence,
        forcedRecovery: true,
      );
    }

    final distance = planDay.targetDistanceKm;
    final duration = planDay.targetDurationMinutes;
    final detailParts = <String>[
      if (distance != null) '${distance.toStringAsFixed(1)} km',
      if (duration != null) '$duration min',
      if (planDay.intensityNote != null) planDay.intensityNote!,
      if (planDay.notes != null) planDay.notes!,
    ];

    if (dailyBrief != null) {
      rationale.add(dailyBrief.recommendation);
      rationale.addAll(dailyBrief.evidence.take(2));
    }

    return TodayDirective(
      headline: planDay.title,
      detail: detailParts.isEmpty
          ? 'Complete today’s prescribed session as written.'
          : detailParts.join(' · '),
      source: TodayDirectiveSource.plan,
      rationale: rationale.where((item) => item.trim().isNotEmpty).take(4).toList(),
      sessionType: planDay.sessionType,
      targetDistanceKm: distance,
      targetDurationMinutes: duration,
      adherence: planDay.adherence,
      forcedRecovery: false,
    );
  }

  bool _shouldForceRecovery({
    required DailyCoachBrief? dailyBrief,
    required MorningCheckIn? morningCheckIn,
    required HealthCheckIn? todayCheckIn,
    required double? readinessScore,
    required double? acwr,
    required List<String> rationale,
  }) {
    var forced = false;
    if (dailyBrief != null &&
        dailyBrief.recommendation.toLowerCase().contains('recovery-biased')) {
      forced = true;
      rationale.add('Daily brief: recovery-biased');
    }
    if (readinessScore != null && readinessScore < 45) {
      forced = true;
      rationale.add('Readiness ${readinessScore.round()}');
    }
    if (acwr != null && acwr > 1.35) {
      forced = true;
      rationale.add('ACWR ${acwr.toStringAsFixed(2)} elevated');
    }
    if (morningCheckIn != null &&
        (morningCheckIn.fatigue >= 7 || morningCheckIn.soreness >= 7)) {
      forced = true;
      rationale.add(
        'Morning check-in fatigue ${morningCheckIn.fatigue}, '
        'soreness ${morningCheckIn.soreness}',
      );
    }
    if (todayCheckIn != null &&
        (todayCheckIn.energy <= 3 ||
            todayCheckIn.soreness >= 8 ||
            todayCheckIn.feelingUnwell)) {
      forced = true;
      rationale.add('Self-report: low energy / high soreness / unwell');
    }
    return forced;
  }
}
