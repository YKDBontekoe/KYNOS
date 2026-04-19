import 'package:health/health.dart';
import 'package:kynos/core/errors/failures.dart';
import 'package:kynos/domain/entities/health_summary.dart';
import 'package:kynos/domain/repositories/health_repository.dart';

/// iOS implementation of [HealthRepository] backed by Apple HealthKit.
///
/// Uses the `health` Flutter plugin under the hood.
/// All data remains on-device in compliance with Zero-Knowledge policy.
class HealthKitRepository implements HealthRepository {
  final Health _health = Health();

  /// Types of health data KYNOS requires for biomechanical coaching.
  static final List<HealthDataType> _types = [
    HealthDataType.HEART_RATE_VARIABILITY_SDNN,
    HealthDataType.RESTING_HEART_RATE,
    HealthDataType.SLEEP_SESSION,
    HealthDataType.ACTIVE_ENERGY_BURNED,
  ];

  @override
  Future<bool> requestPermissions() async {
    try {
      // Requesting read-only permissions for HealthKit.
      final bool requested = await _health.requestAuthorization(_types);
      return requested;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<({List<HealthSummary> summaries, Failure? failure})> getSummaries({
    required int days,
  }) async {
    try {
      final now = DateTime.now();
      final startTime = now.subtract(Duration(days: days));

      // Fetch health data points.
      final List<HealthDataPoint> data = await _health.getHealthDataFromTypes(
        types: _types,
        startTime: startTime,
        endTime: now,
      );

      // Aggregate data by day.
      final Map<DateTime, HealthSummary> aggregated = {};

      for (var point in data) {
        final date = DateTime(point.dateFrom.year, point.dateFrom.month, point.dateFrom.day);
        
        final existing = aggregated[date] ?? HealthSummary(date: date);
        double? hrv = existing.hrvMs;
        double? rhr = existing.rhrBpm;
        double? sleep = existing.sleepHours;
        double? active = existing.activeCalories;

        if (point.type == HealthDataType.HEART_RATE_VARIABILITY_SDNN) {
          hrv = (point.value as NumericHealthValue).numericValue.toDouble();
        } else if (point.type == HealthDataType.RESTING_HEART_RATE) {
          rhr = (point.value as NumericHealthValue).numericValue.toDouble();
        } else if (point.type == HealthDataType.SLEEP_SESSION) {
          // Calculate duration in hours.
          final duration = point.dateTo.difference(point.dateFrom).inMinutes / 60.0;
          sleep = (sleep ?? 0) + duration;
        } else if (point.type == HealthDataType.ACTIVE_ENERGY_BURNED) {
          active = (active ?? 0) + (point.value as NumericHealthValue).numericValue.toDouble();
        }

        aggregated[date] = HealthSummary(
          date: date,
          hrvMs: hrv,
          rhrBpm: rhr,
          sleepHours: sleep,
          activeCalories: active,
        );
      }

      final summaries = aggregated.values.toList()
        ..sort((a, b) => b.date.compareTo(a.date));

      return (summaries: summaries, failure: null);
    } catch (e) {
      return (
        summaries: const <HealthSummary>[],
        failure: HealthDataFailure('Failed to fetch HealthKit data: $e'),
      );
    }
  }

  @override
  Future<({HealthSummary? summary, Failure? failure})> getToday() async {
    final result = await getSummaries(days: 0);
    if (result.failure != null) {
      return (summary: null, failure: result.failure);
    }
    return (
      summary: result.summaries.isNotEmpty ? result.summaries.first : null,
      failure: null,
    );
  }
}
