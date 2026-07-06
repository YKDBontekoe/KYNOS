import 'package:flutter_test/flutter_test.dart';
import 'package:kynos/infrastructure/health/health_summary_merge.dart';

void main() {
  group('HealthSummaryMerge.runningWorkoutDistanceMeters', () {
    test('returns null when both sources empty', () {
      expect(
        HealthSummaryMerge.runningWorkoutDistanceMeters(null, null),
        isNull,
      );
    });

    test('returns single source when other is empty', () {
      expect(
        HealthSummaryMerge.runningWorkoutDistanceMeters(5000, null),
        5000,
      );
    });

    test('deduplicates overlapping HealthKit and import distances', () {
      expect(
        HealthSummaryMerge.runningWorkoutDistanceMeters(8000, 8020),
        8020,
      );
    });

    test('sums distinct runs on the same day', () {
      expect(
        HealthSummaryMerge.runningWorkoutDistanceMeters(5000, 3000),
        8000,
      );
    });
  });

  group('HealthSummaryMerge.runningWorkoutCount', () {
    test('deduplicates when distances overlap', () {
      expect(
        HealthSummaryMerge.runningWorkoutCount(
          a: 1,
          b: 1,
          distanceA: 8000,
          distanceB: 8020,
        ),
        1,
      );
    });

    test('sums when distances differ', () {
      expect(
        HealthSummaryMerge.runningWorkoutCount(
          a: 1,
          b: 1,
          distanceA: 5000,
          distanceB: 3000,
        ),
        2,
      );
    });
  });
}
