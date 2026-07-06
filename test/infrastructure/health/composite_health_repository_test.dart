import 'package:flutter_test/flutter_test.dart';
import 'package:kynos/core/constants/imported_workout_ids.dart';
import 'package:kynos/core/errors/failures.dart';
import 'package:kynos/domain/entities/health_summary.dart';
import 'package:kynos/domain/entities/workout_route_point.dart';
import 'package:kynos/domain/entities/workout_session.dart';
import 'package:kynos/domain/repositories/health_repository.dart';
import 'package:kynos/infrastructure/health/composite_health_repository.dart';

void main() {
  group('CompositeHealthRepository', () {
    test('merges runs and deduplicates overlapping entries', () async {
      final healthKit = _FakeHealthRepository(
        runs: [
          WorkoutSession(
            id: 'hk-1',
            start: DateTime(2026, 4, 20, 7),
            end: DateTime(2026, 4, 20, 7, 45),
            workoutType: 'running',
            distanceMeters: 8000,
            sourceName: 'HealthKit',
          ),
        ],
      );
      final imported = _FakeHealthRepository(
        runs: [
          WorkoutSession(
            id: ImportedWorkoutIds.generate(),
            start: DateTime(2026, 4, 20, 7, 0, 30),
            end: DateTime(2026, 4, 20, 7, 45),
            workoutType: 'running',
            distanceMeters: 8020,
            sourceName: 'GPX import',
          ),
          WorkoutSession(
            id: ImportedWorkoutIds.generate(),
            start: DateTime(2026, 4, 19, 7),
            end: DateTime(2026, 4, 19, 7, 30),
            workoutType: 'running',
            distanceMeters: 5000,
            sourceName: 'GPX import',
          ),
        ],
      );

      final repo = CompositeHealthRepository(
        healthKit: healthKit,
        imported: imported,
      );

      final result = await repo.getRecentRuns(days: 30, limit: 10);

      expect(result.runs, hasLength(2));
      expect(result.runs.first.id, 'hk-1');
    });

    test('routes imported workout lookups to imported repository', () async {
      final importedId = ImportedWorkoutIds.generate();
      final healthKit = _FakeHealthRepository();
      final imported = _FakeHealthRepository(
        routePoints: {
          importedId: const [
            WorkoutRoutePoint(latitude: 1, longitude: 2),
          ],
        },
      );

      final repo = CompositeHealthRepository(
        healthKit: healthKit,
        imported: imported,
      );

      final result = await repo.getRunRoute(workoutUuid: importedId);

      expect(result.points, hasLength(1));
      expect(result.points.first.latitude, 1);
    });

    test('merges summaries by day', () async {
      final day = DateTime(2026, 4, 20);
      final healthKit = _FakeHealthRepository(
        summaries: [
          HealthSummary(date: day, hrvMs: 55, steps: 4000),
        ],
      );
      final imported = _FakeHealthRepository(
        summaries: [
          HealthSummary(
            date: day,
            runningWorkoutCount: 1,
            runningWorkoutDistanceMeters: 5000,
          ),
        ],
      );

      final repo = CompositeHealthRepository(
        healthKit: healthKit,
        imported: imported,
      );

      final result = await repo.getSummaries(days: 7);

      expect(result.summaries, hasLength(1));
      expect(result.summaries.first.hrvMs, 55);
      expect(result.summaries.first.runningWorkoutCount, 1);
    });
  });
}

class _FakeHealthRepository implements HealthRepository {
  _FakeHealthRepository({
    List<WorkoutSession> runs = const [],
    List<HealthSummary> summaries = const [],
    Map<String, List<WorkoutRoutePoint>> routePoints = const {},
  })  : _runs = runs,
        _summaries = summaries,
        _routePoints = routePoints;

  final List<WorkoutSession> _runs;
  final List<HealthSummary> _summaries;
  final Map<String, List<WorkoutRoutePoint>> _routePoints;

  @override
  Future<bool> requestPermissions() async => true;

  @override
  Future<bool> hasPermissions() async => true;

  @override
  Future<({WorkoutSession? workout, Failure? failure})> getWorkoutById({
    required String workoutId,
  }) async {
    for (final run in _runs) {
      if (run.id == workoutId) return (workout: run, failure: null);
    }
    return (workout: null, failure: null);
  }

  @override
  Future<({List<HealthSummary> summaries, Failure? failure})> getSummaries({
    required int days,
  }) async {
    return (summaries: _summaries, failure: null);
  }

  @override
  Future<({List<WorkoutSession> runs, Failure? failure})> getRecentRuns({
    required int days,
    int limit = 30,
  }) async {
    return (runs: _runs, failure: null);
  }

  @override
  Future<({List<WorkoutRoutePoint> points, Failure? failure})> getRunRoute({
    required String workoutUuid,
  }) async {
    return (points: _routePoints[workoutUuid] ?? const [], failure: null);
  }

  @override
  Future<({HealthSummary? summary, Failure? failure})> getToday() async {
    return (
      summary: _summaries.isNotEmpty ? _summaries.first : null,
      failure: null,
    );
  }
}
