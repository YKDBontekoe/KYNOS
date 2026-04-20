import 'package:flutter_test/flutter_test.dart';
import 'package:kynos/core/utils/readiness_calculator.dart';
import 'package:kynos/domain/entities/health_summary.dart';

void main() {
  group('calculateReadiness', () {
    test('returns 0 for null summary', () {
      expect(calculateReadiness(null), 0);
    });

    test('calculates correct score for optimal summary', () {
      final summary = HealthSummary(
        date: DateTime.now(),
        sleepHours: 8.0,
        hrvMs: 65.0,
      );
      // 50 + 25 (sleep) + 25 (hrv) = 100
      expect(calculateReadiness(summary), 100);
    });

    test('calculates correct score for poor summary', () {
      final summary = HealthSummary(
        date: DateTime.now(),
        sleepHours: 4.0,
        hrvMs: 30.0,
      );
      // 50 - 20 (sleep) - 15 (hrv) = 15
      expect(calculateReadiness(summary), 15);
    });

    test('clamps score between 0 and 100', () {
      final goodSummary = HealthSummary(
        date: DateTime.now(),
        sleepHours: 12.0,
        hrvMs: 150.0,
      );
      // 50 + 25 + 25 = 100
      expect(calculateReadiness(goodSummary), 100);
    });
  });
}
