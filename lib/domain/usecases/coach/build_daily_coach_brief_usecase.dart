import 'package:kynos/domain/entities/coach/athlete_coach_profile.dart';
import 'package:kynos/domain/entities/coach/daily_coach_brief.dart';
import 'package:kynos/domain/entities/coach/morning_check_in.dart';
import 'package:kynos/domain/entities/health_summary.dart';
import 'package:kynos/domain/entities/workout_session.dart';

class BuildDailyCoachBriefUseCase {
  const BuildDailyCoachBriefUseCase();

  DailyCoachBrief call({
    required List<HealthSummary> history,
    required List<WorkoutSession> recentRuns,
    AthleteCoachProfile? profile,
    MorningCheckIn? checkIn,
    double? acwr,
  }) {
    final sortedHistory = List<HealthSummary>.from(history)
      ..sort((a, b) => b.date.compareTo(a.date));
    final today = sortedHistory.isEmpty ? null : sortedHistory.first;
    final lowSleep = (today?.sleepHours ?? 8) < 6.5;
    final lowHrv = (today?.hrvMs ?? 50) < 35;
    final subjectiveRisk =
        checkIn != null && (checkIn.fatigue >= 7 || checkIn.soreness >= 7);
    final loadRisk = acwr != null && acwr > 1.3;
    final recoveryBiased = lowSleep || lowHrv || subjectiveRisk || loadRisk;

    final evidence = <String>[
      if (today?.sleepHours != null)
        'sleep ${today!.sleepHours!.toStringAsFixed(1)}h',
      if (today?.hrvMs != null) 'HRV ${today!.hrvMs!.round()}ms',
      if (today?.rhrBpm != null) 'resting HR ${today!.rhrBpm!.round()} bpm',
      if (acwr != null) 'ACWR ${acwr.toStringAsFixed(2)}',
      if (recentRuns.isNotEmpty) '${recentRuns.length} recent runs',
      if (checkIn != null)
        'check-in fatigue ${checkIn.fatigue}/10, soreness ${checkIn.soreness}/10',
    ];
    final available = sortedHistory
        .expand(
          (summary) => [summary.hrvMs, summary.rhrBpm, summary.sleepHours],
        )
        .whereType<double>()
        .length;
    final quality = available >= 6
        ? 'good'
        : available >= 3
        ? 'partial'
        : 'limited';

    return DailyCoachBrief(
      recommendation: recoveryBiased
          ? 'recovery-biased: easy movement or rest; avoid hard intervals'
          : 'normal training is reasonable; start controlled and reassess',
      confidence: quality == 'good'
          ? 'high'
          : quality == 'partial'
          ? 'medium'
          : 'low',
      evidence: evidence.take(4).toList(),
      dataQuality: quality,
      checkIn: checkIn,
      profile: profile,
    );
  }
}
