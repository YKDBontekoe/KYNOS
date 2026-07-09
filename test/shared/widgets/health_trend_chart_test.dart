import 'package:flutter_test/flutter_test.dart';
import 'package:kynos/domain/entities/health_summary.dart';
import 'package:kynos/shared/widgets/charts/health_trend_chart.dart';

void main() {
  final now = DateTime.now();

  HealthSummary summary(int daysAgo, {double? hrv, double? calories}) =>
      HealthSummary(
        date: now.subtract(Duration(days: daysAgo)),
        hrvMs: hrv,
        activeCalories: calories,
      );

  test('builds recent recovery points and ignores missing values', () {
    final points = buildHealthTrendPoints(
      [summary(1, hrv: 52), summary(2), summary(8, hrv: 41)],
      metric: HealthChartMetric.recovery,
      range: HealthChartRange.week,
    );

    expect(points, hasLength(1));
    expect(points.single.value, 52);
  });

  test('aggregates the year view into weekly averages', () {
    final points = buildHealthTrendPoints(
      [summary(1, hrv: 50), summary(2, hrv: 60)],
      metric: HealthChartMetric.recovery,
      range: HealthChartRange.year,
    );

    expect(points, hasLength(1));
    expect(points.single.value, 55);
  });

  test('supports activity metrics with their display unit', () {
    expect(HealthChartMetric.activeEnergy.unit, 'kcal');
    final points = buildHealthTrendPoints(
      [summary(1, calories: 420)],
      metric: HealthChartMetric.activeEnergy,
      range: HealthChartRange.week,
    );
    expect(points.single.value, 420);
  });
}
