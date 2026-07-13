import 'package:flutter_test/flutter_test.dart';
import 'package:kynos/domain/entities/health/health_coach_models.dart';
import 'package:kynos/domain/entities/health_summary.dart';
import 'package:kynos/domain/usecases/health/build_daily_health_brief_usecase.dart';
import 'package:kynos/domain/utils/health_safety_policy.dart';

void main() {
  const useCase = BuildDailyHealthBriefUseCase();
  final today = DateTime(2026, 7, 13);

  List<HealthSummary> stableHistory({
    double todayHrv = 50,
    double todaySleep = 7.5,
    int todaySteps = 8000,
  }) => [
    HealthSummary(
      date: today,
      hrvMs: todayHrv,
      rhrBpm: 52,
      sleepHours: todaySleep,
      steps: todaySteps,
    ),
    for (var day = 1; day <= 20; day++)
      HealthSummary(
        date: today.subtract(Duration(days: day)),
        hrvMs: 48 + (day % 5).toDouble(),
        rhrBpm: 50 + (day % 5).toDouble(),
        sleepHours: 7 + (day % 5) * 0.1,
        steps: 7500 + (day % 5) * 250,
      ),
  ];

  test(
    'returns a deterministic stable brief with no more than three findings',
    () {
      final first = useCase(
        history: stableHistory(todayHrv: 20, todaySleep: 3, todaySteps: 1000),
        now: today,
      );
      final second = useCase(
        history: stableHistory(todayHrv: 20, todaySleep: 3, todaySteps: 1000),
        now: today,
      );

      expect(first.baselineQuality, BaselineQuality.stable);
      expect(first.findings.length, lessThanOrEqualTo(3));
      expect(first.fingerprint, second.fingerprint);
      expect(first.primaryAction, isNotEmpty);
    },
  );

  test('prioritises a low-energy self report over wearable optimism', () {
    final brief = useCase(
      history: stableHistory(),
      checkIn: HealthCheckIn(
        date: today,
        energy: 1,
        mood: 3,
        stress: 3,
        soreness: 2,
      ),
      now: today,
    );

    expect(brief.findings.first.basis, FindingBasis.selfReported);
    expect(brief.primaryAction, contains('gentle 10-minute'));
  });

  test('uses static urgent guidance instead of model-authored triage', () {
    final brief = useCase(
      history: stableHistory(),
      checkIn: HealthCheckIn(
        date: today,
        energy: 1,
        mood: 1,
        stress: 5,
        soreness: 4,
        feelingUnwell: true,
        note: 'I have chest pain',
      ),
      now: today,
    );

    expect(brief.primaryAction, HealthSafetyPolicy.urgentGuidance);
    expect(brief.bodyStateSummary, contains('immediate human attention'));
  });

  test('surfaces sparse baseline quality without inventing findings', () {
    final brief = useCase(
      history: [HealthSummary(date: today, hrvMs: 55)],
      now: today,
    );

    expect(brief.baselineQuality, BaselineQuality.learning);
    expect(brief.findings, isEmpty);
    expect(brief.bodyStateSummary, contains('learning'));
  });
}
