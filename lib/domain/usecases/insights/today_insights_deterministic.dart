import 'package:kynos/domain/entities/health_summary.dart';
import 'package:kynos/domain/entities/insights/insight_confidence.dart';
import 'package:kynos/domain/entities/insights/today_insights.dart';
import 'package:kynos/domain/utils/readiness_score.dart';

/// Builds deterministic today insights from health metrics.
TodayInsights buildTodayInsightsDeterministic({
  required HealthSummary today,
  required HealthSummary? yesterday,
}) {
  final readiness = readinessScore(today);

  final whatChanged = <String>[
    ..._deltaLine(
      label: 'Recovery (HRV)',
      today: today.hrvMs,
      yesterday: yesterday?.hrvMs,
      unit: 'ms',
      higherIsBetter: true,
    ),
    ..._deltaLine(
      label: 'Resting pulse',
      today: today.rhrBpm,
      yesterday: yesterday?.rhrBpm,
      unit: 'bpm',
      higherIsBetter: false,
    ),
    ..._deltaLine(
      label: 'Sleep',
      today: today.sleepHours,
      yesterday: yesterday?.sleepHours,
      unit: 'h',
      higherIsBetter: true,
      digits: 1,
    ),
  ];

  final riskFlags = <String>[];
  if ((today.sleepHours ?? 0) < 6) {
    riskFlags.add('Sleep debt: keep intensity lower today.');
  }
  if ((today.hrvMs ?? 0) < 35) {
    riskFlags.add('Low recovery score (HRV): strain is elevated.');
  }
  if ((today.rhrBpm ?? 999) > 70) {
    riskFlags.add('High resting pulse: possible fatigue signal.');
  }
  if (readiness < 45) {
    riskFlags.add('Low readiness: overreaching risk is higher.');
  }
  if (riskFlags.isEmpty) {
    riskFlags.add('No strong risk signal today.');
  }

  final actionNow = readiness >= 70
      ? 'Run quality as planned. Start controlled.'
      : readiness >= 50
      ? 'Keep it aerobic. Cap effort at RPE 6-7.'
      : 'Switch to easy run or brisk walk. Cut volume ~20%.';

  final actionTonight = (today.sleepHours ?? 0) < 7
      ? 'Wind down early. Target 8+ hours in bed.'
      : 'Hydrate and hit protein to support tomorrow.';

  final evidence = <String>[
    if (today.hrvMs != null) 'Recovery ${today.hrvMs!.round()} ms',
    if (today.rhrBpm != null) 'Resting pulse ${today.rhrBpm!.round()} bpm',
    if (today.sleepHours != null)
      'Sleep ${today.sleepHours!.toStringAsFixed(1)} h',
    if (today.runningWorkoutDistanceMeters != null)
      'Run ${(today.runningWorkoutDistanceMeters! / 1000).toStringAsFixed(2)} km',
    if (today.steps != null) 'Steps ${today.steps}',
  ];

  final confidence = _confidenceForToday(today);

  return TodayInsights(
    readinessBrief: readinessSummaryBrief(readiness),
    whatChanged: whatChanged.take(3).toList(),
    riskFlags: riskFlags.take(3).toList(),
    actionNow: actionNow,
    actionTonight: actionTonight,
    evidence: evidence.take(4).toList(),
    confidence: confidence,
  );
}

HealthSummary? findYesterdaySummary(
  List<HealthSummary> history,
  DateTime todayDate,
) {
  final dayStart = DateTime(todayDate.year, todayDate.month, todayDate.day);
  final yesterdayStart = dayStart.subtract(const Duration(days: 1));
  for (final sample in history.reversed) {
    final sampleDay = DateTime(
      sample.date.year,
      sample.date.month,
      sample.date.day,
    );
    if (sampleDay == yesterdayStart) return sample;
  }
  return null;
}

List<String> _deltaLine({
  required String label,
  required double? today,
  required double? yesterday,
  required String unit,
  required bool higherIsBetter,
  int digits = 0,
}) {
  if (today == null || yesterday == null) return const [];
  final delta = today - yesterday;
  if (delta.abs() < 0.001) return const [];

  final improved = higherIsBetter ? delta > 0 : delta < 0;
  final trend = improved
      ? 'improved'
      : delta > 0
      ? 'increased'
      : 'decreased';
  final sign = delta > 0 ? '+' : '';
  final todayLabel = digits == 0
      ? today.round().toString()
      : today.toStringAsFixed(digits);
  final deltaLabel = digits == 0
      ? delta.round().toString()
      : delta.toStringAsFixed(digits);
  return [
    '$label $trend to $todayLabel $unit ($sign$deltaLabel vs yesterday).',
  ];
}

InsightConfidence _confidenceForToday(HealthSummary today) {
  var available = 0;
  if (today.hrvMs != null) available++;
  if (today.rhrBpm != null) available++;
  if (today.sleepHours != null) available++;
  if (today.bloodOxygenPercent != null) available++;

  if (available >= 4) return InsightConfidence.high;
  if (available >= 2) return InsightConfidence.medium;
  return InsightConfidence.low;
}
