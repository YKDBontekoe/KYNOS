import 'package:flutter_test/flutter_test.dart';
import 'package:kynos/domain/entities/workout_route_point.dart';
import 'package:kynos/domain/entities/workout_session.dart';
import 'package:kynos/domain/utils/pace_format.dart';
import 'package:kynos/domain/utils/run_route_analytics.dart';

WorkoutSession _session({
  required DateTime start,
  required Duration duration,
  double? distanceMeters,
}) {
  return WorkoutSession(
    id: 'run-1',
    start: start,
    end: start.add(duration),
    workoutType: 'running',
    distanceMeters: distanceMeters,
    sourceName: 'Test',
  );
}

List<WorkoutRoutePoint> _straightRoute({
  required int pointCount,
  required Duration segmentDuration,
  double metersPerSegment = 100,
}) {
  final start = DateTime.utc(2026, 1, 1, 8);
  final points = <WorkoutRoutePoint>[];
  for (var i = 0; i < pointCount; i++) {
    points.add(
      WorkoutRoutePoint(
        latitude: 51.5 + (i * metersPerSegment) / 111000,
        longitude: -0.12,
        timestamp: start.add(segmentDuration * i),
      ),
    );
  }
  return points;
}

void main() {
  group('computeRunRouteAnalytics', () {
    test('computes average pace from session distance', () {
      final session = _session(
        start: DateTime.utc(2026, 1, 1),
        duration: const Duration(minutes: 30),
        distanceMeters: 5000,
      );

      final analytics = computeRunRouteAnalytics(session: session, points: const []);

      expect(analytics.avgPaceSecondsPerKm, closeTo(360, 1));
      expect(formatPacePerKm(analytics.avgPaceSecondsPerKm!), '6:00 /km');
    });

    test('builds pace profile when timestamps exist', () {
      final session = _session(
        start: DateTime.utc(2026, 1, 1, 8),
        duration: const Duration(minutes: 20),
        distanceMeters: 4000,
      );
      final points = _straightRoute(
        pointCount: 40,
        segmentDuration: const Duration(seconds: 30),
        metersPerSegment: 100,
      );

      final analytics = computeRunRouteAnalytics(session: session, points: points);

      expect(analytics.hasPaceProfile, isTrue);
      expect(analytics.paceProfile.first.distanceKm, greaterThan(0));
      expect(analytics.paceProfile.first.paceSecondsPerKm, greaterThan(0));
    });

    test('builds kilometer splits for long enough routes', () {
      final session = _session(
        start: DateTime.utc(2026, 1, 1, 8),
        duration: const Duration(minutes: 40),
        distanceMeters: 5000,
      );
      final points = _straightRoute(
        pointCount: 51,
        segmentDuration: const Duration(seconds: 48),
        metersPerSegment: 100,
      );

      final analytics = computeRunRouteAnalytics(session: session, points: points);

      expect(analytics.hasSplits, isTrue);
      expect(analytics.kilometerSplits.length, greaterThanOrEqualTo(4));
      expect(analytics.fastestSplitIndex, isNotNull);
      expect(analytics.slowestSplitIndex, isNotNull);
    });

    test('returns empty profile without timestamps', () {
      final session = _session(
        start: DateTime.utc(2026, 1, 1),
        duration: const Duration(minutes: 20),
        distanceMeters: 3000,
      );
      final points = [
        const WorkoutRoutePoint(latitude: 51.5, longitude: -0.12),
        const WorkoutRoutePoint(latitude: 51.51, longitude: -0.12),
        const WorkoutRoutePoint(latitude: 51.52, longitude: -0.12),
      ];

      final analytics = computeRunRouteAnalytics(session: session, points: points);

      expect(analytics.paceProfile, isEmpty);
      expect(analytics.kilometerSplits, isEmpty);
      expect(analytics.gpsDistanceMeters, greaterThan(0));
    });

    test('handles single point gracefully', () {
      final session = _session(
        start: DateTime.utc(2026, 1, 1),
        duration: const Duration(minutes: 10),
      );
      final analytics = computeRunRouteAnalytics(
        session: session,
        points: const [
          WorkoutRoutePoint(latitude: 51.5, longitude: -0.12),
        ],
      );

      expect(analytics.gpsDistanceMeters, 0);
      expect(analytics.paceProfile, isEmpty);
    });
  });

  group('paceConsistencyScore', () {
    test('returns lower score for consistent splits', () {
      final splits = [
        const KilometerSplit(
          kilometer: 1,
          duration: Duration(minutes: 5),
          paceSecondsPerKm: 300,
        ),
        const KilometerSplit(
          kilometer: 2,
          duration: Duration(minutes: 5),
          paceSecondsPerKm: 305,
        ),
        const KilometerSplit(
          kilometer: 3,
          duration: Duration(minutes: 5),
          paceSecondsPerKm: 295,
        ),
      ];

      final score = paceConsistencyScore(splits);
      expect(score, isNotNull);
      expect(score, lessThan(0.05));
    });
  });
}
