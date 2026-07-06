import 'package:kynos/core/errors/failures.dart';
import 'package:kynos/domain/entities/health_summary.dart';
import 'package:kynos/domain/entities/workout_route_point.dart';
import 'package:kynos/domain/entities/workout_session.dart';

/// Contract for accessing biometric data from the platform health store.
///
/// Implementations: [HealthKitRepository] (iOS), [HealthConnectRepository] (Android).
abstract interface class HealthRepository {
  /// Requests platform permission to read health data.
  Future<bool> requestPermissions();

  /// Returns whether read permission has been granted for core health types.
  Future<bool> hasPermissions();

  /// Returns a single workout by platform or imported id, without a recency window.
  Future<({WorkoutSession? workout, Failure? failure})> getWorkoutById({
    required String workoutId,
  });

  /// Returns aggregated daily summaries for the past [days] days.
  Future<({List<HealthSummary> summaries, Failure? failure})> getSummaries({
    required int days,
  });

  /// Returns recent running workouts for the past [days] days.
  Future<({List<WorkoutSession> runs, Failure? failure})> getRecentRuns({
    required int days,
    int limit = 30,
  });

  /// Returns route points for a given workout session UUID.
  Future<({List<WorkoutRoutePoint> points, Failure? failure})> getRunRoute({
    required String workoutUuid,
  });

  /// Returns the most recent single-day summary.
  Future<({HealthSummary? summary, Failure? failure})> getToday();
}
