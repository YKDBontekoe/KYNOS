import 'package:flutter_test/flutter_test.dart';
import 'package:kynos/domain/entities/health_summary.dart';
import 'package:kynos/domain/utils/running_distance.dart';

void main() {
  group('dailyRunningDistanceKm', () {
    test('uses only running workout distance', () {
      final summary = HealthSummary(
        date: DateTime(2026, 4, 20),
        distanceMeters: 12000,
        runningWorkoutDistanceMeters: 5000,
      );

      expect(dailyRunningDistanceKm(summary), closeTo(5, 0.01));
    });

    test('ignores walking distance when no run recorded', () {
      final summary = HealthSummary(
        date: DateTime(2026, 4, 20),
        distanceMeters: 8000,
      );

      expect(dailyRunningDistanceKm(summary), 0);
    });
  });
}
