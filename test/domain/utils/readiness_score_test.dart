import 'package:flutter_test/flutter_test.dart';
import 'package:kynos/domain/entities/health_summary.dart';
import 'package:kynos/domain/utils/readiness_score.dart';

void main() {
  group('readinessDimensions', () {
    test('returns per-metric scores between 0 and 1', () {
      final summary = HealthSummary(
        date: DateTime(2026, 4, 20),
        hrvMs: 65,
        rhrBpm: 55,
        sleepHours: 7.5,
        bloodOxygenPercent: 98,
      );

      final dimensions = readinessDimensions(summary);

      expect(dimensions.hrv, greaterThan(0));
      expect(dimensions.hrv, lessThanOrEqualTo(1));
      expect(dimensions.rhr, greaterThan(0));
      expect(dimensions.rhr, lessThanOrEqualTo(1));
      expect(dimensions.sleep, greaterThan(0));
      expect(dimensions.sleep, lessThanOrEqualTo(1));
      expect(dimensions.spo2, greaterThan(0));
      expect(dimensions.spo2, lessThanOrEqualTo(1));
      expect(dimensions.ringProgresses, hasLength(4));
    });

    test('returns zeros for missing metrics in a partial summary', () {
      final summary = HealthSummary(
        date: DateTime(2026, 4, 20),
        hrvMs: 65,
        sleepHours: 7.5,
      );

      final dimensions = readinessDimensions(summary);

      expect(dimensions.hrv, greaterThan(0));
      expect(dimensions.rhr, 0);
      expect(dimensions.sleep, greaterThan(0));
      expect(dimensions.spo2, 0);
    });

    test('returns zeros when summary is null', () {
      final dimensions = readinessDimensions(null);

      expect(dimensions.hrv, 0);
      expect(dimensions.rhr, 0);
      expect(dimensions.sleep, 0);
      expect(dimensions.spo2, 0);
    });
  });
}
