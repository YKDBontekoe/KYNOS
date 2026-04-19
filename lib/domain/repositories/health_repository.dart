import 'package:kynos/core/errors/failures.dart';
import 'package:kynos/domain/entities/health_summary.dart';

/// Contract for accessing biometric data from the platform health store.
///
/// Implementations: [HealthKitRepository] (iOS), [HealthConnectRepository] (Android).
abstract interface class HealthRepository {
  /// Requests platform permission to read health data.
  Future<bool> requestPermissions();

  /// Returns aggregated daily summaries for the past [days] days.
  Future<({List<HealthSummary> summaries, Failure? failure})> getSummaries({
    required int days,
  });

  /// Returns the most recent single-day summary.
  Future<({HealthSummary? summary, Failure? failure})> getToday();
}
