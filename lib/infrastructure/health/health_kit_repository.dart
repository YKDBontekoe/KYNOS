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
  bool _isConfigured = false;

  /// Types of health data KYNOS requires for biomechanical coaching.
  static final List<HealthDataType> _types = [
    HealthDataType.HEART_RATE_VARIABILITY_SDNN,
    HealthDataType.RESTING_HEART_RATE,
    HealthDataType.SLEEP_ASLEEP,
    HealthDataType.SLEEP_IN_BED,
    HealthDataType.ACTIVE_ENERGY_BURNED,
  ];

  Future<void> _ensureConfigured() async {
    if (!_isConfigured) {
      await _health.configure();
      _isConfigured = true;
    }
  }

  @override
  Future<bool> requestPermissions() async {
    await _ensureConfigured();
    // Explicitly demand READ-ONLY access. By default ^12.2.0 tries
    // READ_WRITE, which can crash violently if iOS rejects write capabilities.
    final permissions = _types.map((e) => HealthDataAccess.READ).toList();
    return await _health.requestAuthorization(_types, permissions: permissions);
  }

  @override
  Future<({List<HealthSummary> summaries, Failure? failure})> getSummaries({
    required int days,
  }) async {
    try {
      await _ensureConfigured();
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
        final date = DateTime(
          point.dateFrom.year,
          point.dateFrom.month,
          point.dateFrom.day,
        );

        final existing = aggregated[date] ?? HealthSummary(date: date);
        double? hrv = existing.hrvMs;
        double? rhr = existing.rhrBpm;
        double? sleep = existing.sleepHours;
        double? active = existing.activeCalories;

        if (point.type == HealthDataType.HEART_RATE_VARIABILITY_SDNN) {
          hrv = (point.value as NumericHealthValue).numericValue.toDouble();
        } else if (point.type == HealthDataType.RESTING_HEART_RATE) {
          rhr = (point.value as NumericHealthValue).numericValue.toDouble();
        } else if (point.type == HealthDataType.SLEEP_ASLEEP ||
            point.type == HealthDataType.SLEEP_IN_BED) {
          // Calculate duration in hours.
          final duration =
              point.dateTo.difference(point.dateFrom).inMinutes / 60.0;
          sleep = (sleep ?? 0) + duration;
        } else if (point.type == HealthDataType.ACTIVE_ENERGY_BURNED) {
          active =
              (active ?? 0) +
              (point.value as NumericHealthValue).numericValue.toDouble();
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
        failure: HealthDataFailure(e.toString()),
      );
    }
  }

  @override
  Future<({HealthSummary? summary, Failure? failure})> getToday() async {
    // days: 1 = past 24 h — covers today regardless of time-of-day.
    // days: 0 would set startTime = endTime = now (zero-second window).
    final result = await getSummaries(days: 1);
    if (result.failure != null) {
      return (summary: null, failure: result.failure);
    }
    return (
      summary: result.summaries.isNotEmpty ? result.summaries.first : null,
      failure: null,
    );
  }
}
