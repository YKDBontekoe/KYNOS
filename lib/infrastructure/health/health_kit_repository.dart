import 'package:kynos/core/errors/failures.dart';
import 'package:kynos/domain/entities/health_summary.dart';
import 'package:kynos/domain/repositories/health_repository.dart';

/// iOS implementation of [HealthRepository] backed by Apple HealthKit.
///
/// Uses the `health` Flutter plugin under the hood.
/// All data remains on-device in compliance with Zero-Knowledge policy.
class HealthKitRepository implements HealthRepository {
  @override
  Future<bool> requestPermissions() async {
    // TODO(health): Call health plugin to request HRV, RHR, Sleep, ActiveEnergy.
    return false;
  }

  @override
  Future<({List<HealthSummary> summaries, Failure? failure})> getSummaries({
    required int days,
  }) async {
    // TODO(health): Query HealthKit for the past [days] days and aggregate.
    return (
      summaries: const <HealthSummary>[],
      failure: const HealthDataFailure('HealthKit not yet integrated'),
    );
  }

  @override
  Future<({HealthSummary? summary, Failure? failure})> getToday() async {
    // TODO(health): Return today's aggregated HealthKit data.
    return (
      summary: null,
      failure: const HealthDataFailure('HealthKit not yet integrated'),
    );
  }
}
