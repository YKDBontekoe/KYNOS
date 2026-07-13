import 'dart:convert';

import 'package:kynos/domain/entities/health/health_coach_models.dart';
import 'package:kynos/domain/entities/health/health_metric.dart';
import 'package:kynos/domain/entities/health_summary.dart';
import 'package:kynos/domain/utils/health_coach_analysis.dart';
import 'package:kynos/domain/utils/health_safety_policy.dart';

class BuildDailyHealthBriefUseCase {
  const BuildDailyHealthBriefUseCase();

  DailyHealthBrief call({
    required List<HealthSummary> history,
    HealthCheckIn? checkIn,
    DateTime? now,
  }) {
    final today = _dateOnly(now ?? DateTime.now());
    final urgentSelfReport = HealthSafetyPolicy.hasUrgentSelfReport(checkIn);
    final todaySummary = _summaryForDate(history, today);
    final findings = <HealthFinding>[];

    for (final metric in const [
      HealthMetric.sleep,
      HealthMetric.hrv,
      HealthMetric.restingHeartRate,
      HealthMetric.steps,
    ]) {
      final current = todaySummary == null
          ? null
          : metric.valueFrom(todaySummary);
      final baseline = HealthCoachAnalysis.baseline(
        history,
        metric,
        asOf: today,
      );
      if (current == null || baseline == null) continue;
      final deviation = HealthCoachAnalysis.robustDeviation(current, baseline);
      if (deviation == null || deviation.abs() < 2.5) continue;
      final direction = current >= baseline.median ? 'above' : 'below';
      findings.add(
        HealthFinding(
          id: '${metric.name}_${today.toIso8601String()}',
          observation:
              '${metric.label} is meaningfully $direction your personal baseline.',
          evidence: [
            '${_format(current)} ${metric.unit} today',
            '${_format(baseline.median)} ${metric.unit} baseline',
          ],
          confidence: baseline.quality == BaselineQuality.stable
              ? FindingConfidence.high
              : FindingConfidence.low,
          basis: FindingBasis.measured,
          limitations: baseline.quality == BaselineQuality.learning
              ? ['KYNOS is still learning your personal baseline.']
              : const [],
          metric: metric,
        ),
      );
    }

    if (checkIn != null && (checkIn.energy <= 2 || checkIn.feelingUnwell)) {
      findings.insert(
        0,
        HealthFinding(
          id: 'check_in_${today.toIso8601String()}',
          observation: checkIn.feelingUnwell
              ? 'You reported feeling unwell today.'
              : 'You reported lower energy today.',
          evidence: ['Energy ${checkIn.energy}/5'],
          confidence: FindingConfidence.high,
          basis: FindingBasis.selfReported,
        ),
      );
    }

    final limitedFindings = findings.take(3).toList(growable: false);
    final baselineCount =
        HealthCoachAnalysis.baseline(
          history,
          HealthMetric.restingHeartRate,
          asOf: today,
        )?.observationCount ??
        0;
    final baselineQuality =
        baselineCount >= HealthCoachAnalysis.stableBaselineObservations
        ? BaselineQuality.stable
        : BaselineQuality.learning;
    final isLowEnergy = checkIn != null && checkIn.energy <= 2;
    final isUnwell = checkIn?.feelingUnwell ?? false;
    final summary = urgentSelfReport
        ? 'Your check-in includes a symptom that needs immediate human attention.'
        : isUnwell
        ? 'Take today gently and prioritise how you feel over wearable scores.'
        : limitedFindings.isEmpty
        ? baselineQuality == BaselineQuality.learning
              ? 'KYNOS is learning what a normal day looks like for you.'
              : 'Your available signals look close to your usual pattern.'
        : 'A few signals differ from your usual pattern today.';
    final primaryAction = urgentSelfReport
        ? HealthSafetyPolicy.urgentGuidance
        : isUnwell
        ? 'Pause strenuous activity and focus on rest. Seek professional advice if symptoms concern you.'
        : isLowEnergy
        ? 'Choose a gentle 10-minute outdoor walk and reassess your energy afterwards.'
        : _actionFor(limitedFindings);

    return DailyHealthBrief(
      date: today,
      bodyStateSummary: summary,
      findings: limitedFindings,
      primaryAction: primaryAction,
      alternativeAction:
          'Take two quiet minutes to check in with how you feel.',
      fingerprint: base64Url.encode(
        utf8.encode(
          '${today.toIso8601String()}|${todaySummary?.toJson()}|$checkIn',
        ),
      ),
      baselineQuality: baselineQuality,
    );
  }

  static String _actionFor(List<HealthFinding> findings) {
    if (findings.any((item) => item.metric == HealthMetric.sleep)) {
      return 'Protect a consistent wind-down time tonight and keep today flexible.';
    }
    if (findings.any((item) => item.metric == HealthMetric.steps)) {
      return 'Add one comfortable movement break before the end of the day.';
    }
    return 'Get a little daylight and gentle movement, then notice how your energy responds.';
  }

  static HealthSummary? _summaryForDate(
    List<HealthSummary> history,
    DateTime date,
  ) {
    for (final summary in history) {
      if (_dateOnly(summary.date) == date) return summary;
    }
    return null;
  }

  static String _format(double value) =>
      value.abs() >= 100 ? value.round().toString() : value.toStringAsFixed(1);

  static DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);
}
