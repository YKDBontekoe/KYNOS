import 'package:kynos/domain/entities/health_summary.dart';

/// Running-only distance in meters for a daily summary.
///
/// Does not include walking or general movement — only recorded running
/// workouts ([HealthSummary.runningWorkoutDistanceMeters]).
double dailyRunningDistanceMeters(HealthSummary summary) =>
    summary.runningWorkoutDistanceMeters ?? 0;

/// Running-only distance in kilometers for a daily summary.
double dailyRunningDistanceKm(HealthSummary summary) =>
    dailyRunningDistanceMeters(summary) / 1000;
