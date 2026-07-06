import 'package:kynos/domain/entities/health_summary.dart';
import 'package:kynos/domain/entities/workout_route_point.dart';
import 'package:kynos/domain/entities/workout_session.dart';

/// A running workout parsed from an Apple Health export.
class AppleHealthWorkoutImport {
  const AppleHealthWorkoutImport({
    required this.workout,
    this.routePoints = const [],
  });

  final WorkoutSession workout;
  final List<WorkoutRoutePoint> routePoints;
}

/// Result of parsing an Apple Health `export.zip` archive.
class AppleHealthExportParseResult {
  const AppleHealthExportParseResult({
    required this.summaries,
    required this.workouts,
    required this.recordCount,
    required this.skippedWorkouts,
  });

  final List<HealthSummary> summaries;
  final List<AppleHealthWorkoutImport> workouts;
  final int recordCount;
  final int skippedWorkouts;
}

/// Domain-safe parser boundary for Apple Health export archives.
abstract interface class AppleHealthExportParser {
  Future<AppleHealthExportParseResult> parse({
    List<int>? zipBytes,
    String? zipPath,
  });
}
