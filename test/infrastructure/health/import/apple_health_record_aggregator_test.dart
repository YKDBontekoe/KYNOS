import 'package:flutter_test/flutter_test.dart';
import 'package:kynos/infrastructure/health/import/apple_health_record_aggregator.dart';

void main() {
  group('AppleHealthRecordAggregator', () {
    test('aggregates steps, HRV, sleep, and activity ring data', () {
      final aggregator = AppleHealthRecordAggregator();

      aggregator
        ..addRecord(
          type: 'HKQuantityTypeIdentifierStepCount',
          value: '5000',
          unit: 'count',
          startDate: '2026-04-20 08:00:00 +0000',
          endDate: '2026-04-20 08:05:00 +0000',
        )
        ..addRecord(
          type: 'HKQuantityTypeIdentifierHeartRateVariabilitySDNN',
          value: '55',
          unit: 'ms',
          startDate: '2026-04-20 07:30:00 +0000',
          endDate: '2026-04-20 07:30:00 +0000',
        )
        ..addRecord(
          type: 'HKCategoryTypeIdentifierSleepAnalysis',
          value: 'HKCategoryValueSleepAnalysisAsleep',
          startDate: '2026-04-20 23:00:00 +0000',
          endDate: '2026-04-21 07:00:00 +0000',
        )
        ..addActivitySummary(
          dateComponents: '2026-04-20',
          activeEnergyBurned: '400',
          activeEnergyBurnedUnit: 'kcal',
          appleExerciseTime: '30',
        );

      final summaries = aggregator.finalize();
      expect(summaries, hasLength(1));

      final summary = summaries.first;
      expect(summary.steps, 5000);
      expect(summary.hrvMs, 55);
      expect(summary.sleepHours, 8);
      expect(summary.activeCalories, 400);
      expect(summary.exerciseMinutes, 30);
    });

    test('does not double-count active calories or exercise minutes', () {
      final aggregator = AppleHealthRecordAggregator();

      aggregator
        ..addRecord(
          type: 'HKQuantityTypeIdentifierActiveEnergyBurned',
          value: '200',
          unit: 'kcal',
          startDate: '2026-04-20 08:00:00 +0000',
          endDate: '2026-04-20 08:05:00 +0000',
        )
        ..addRecord(
          type: 'HKQuantityTypeIdentifierAppleExerciseTime',
          value: '15',
          unit: 'min',
          startDate: '2026-04-20 08:00:00 +0000',
          endDate: '2026-04-20 08:05:00 +0000',
        )
        ..addActivitySummary(
          dateComponents: '2026-04-20',
          activeEnergyBurned: '400',
          activeEnergyBurnedUnit: 'kcal',
          appleExerciseTime: '30',
        );

      final summary = aggregator.finalize().first;
      expect(summary.activeCalories, 400);
      expect(summary.exerciseMinutes, 30);
    });
  });
}
