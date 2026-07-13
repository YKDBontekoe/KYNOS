import 'package:flutter_test/flutter_test.dart';
import 'package:kynos/domain/entities/health/health_coach_models.dart';
import 'package:kynos/domain/entities/health/health_metric.dart';
import 'package:kynos/domain/entities/health_summary.dart';
import 'package:kynos/domain/utils/health_coach_analysis.dart';

void main() {
  group('HealthCoachAnalysis.baseline', () {
    final today = DateTime(2026, 7, 13);

    test(
      'uses the trailing 28 days, excludes today, and becomes stable at 14',
      () {
        final history = [
          HealthSummary(date: today, hrvMs: 500),
          for (var day = 1; day <= 14; day++)
            HealthSummary(
              date: today.subtract(Duration(days: day)),
              hrvMs: 40 + day.toDouble(),
            ),
          HealthSummary(
            date: today.subtract(const Duration(days: 29)),
            hrvMs: 900,
          ),
        ];

        final result = HealthCoachAnalysis.baseline(
          history,
          HealthMetric.hrv,
          asOf: today,
        );

        expect(result, isNotNull);
        expect(result!.observationCount, 14);
        expect(result.quality, BaselineQuality.stable);
        expect(result.median, 47.5);
      },
    );

    test('marks sparse history as learning', () {
      final result = HealthCoachAnalysis.baseline(
        [
          for (var day = 1; day <= 13; day++)
            HealthSummary(
              date: today.subtract(Duration(days: day)),
              rhrBpm: 50,
            ),
        ],
        HealthMetric.restingHeartRate,
        asOf: today,
      );

      expect(result!.quality, BaselineQuality.learning);
    });
  });

  test('robust deviation uses median absolute deviation', () {
    final baseline = PersonalBaseline(
      metric: HealthMetric.hrv,
      observationCount: 14,
      median: 50,
      medianAbsoluteDeviation: 2,
      start: DateTime(2026, 6, 15),
      end: DateTime(2026, 7, 13),
      quality: BaselineQuality.stable,
    );

    expect(
      HealthCoachAnalysis.robustDeviation(60, baseline),
      closeTo(3.3725, 0.0001),
    );
  });

  group('HealthCoachAnalysis.spearman', () {
    test('requires ten paired observations', () {
      final pairs = [
        for (var index = 0; index < 9; index++)
          (x: index.toDouble(), y: index.toDouble()),
      ];

      expect(HealthCoachAnalysis.spearman(pairs), isNull);
    });

    test('returns strong monotonic association and handles tied ranks', () {
      final pairs = [
        for (var index = 0; index < 10; index++)
          (x: (index ~/ 2).toDouble(), y: index.toDouble()),
      ];

      final coefficient = HealthCoachAnalysis.spearman(pairs);
      if (coefficient == null) fail('Expected a meaningful association.');
      expect(coefficient, greaterThan(0.9));
      expect(HealthCoachAnalysis.associationStrength(coefficient), 'strong');
    });

    test('suppresses associations below the meaningful threshold', () {
      final y = [5, 1, 9, 3, 7, 2, 10, 6, 4, 8];
      final pairs = [
        for (var index = 0; index < y.length; index++)
          (x: index.toDouble(), y: y[index].toDouble()),
      ];

      expect(HealthCoachAnalysis.spearman(pairs), isNull);
    });
  });
}
