import 'package:kynos/core/constants/imported_workout_ids.dart';
import 'package:kynos/domain/entities/workout_route_point.dart';
import 'package:kynos/domain/entities/workout_session.dart';
import 'package:kynos/domain/utils/geo_distance.dart';
import 'package:xml/xml.dart';

/// Result of parsing a GPX file into a workout and optional route.
class GpxParseResult {
  const GpxParseResult({
    required this.workout,
    required this.routePoints,
  });

  final WorkoutSession workout;
  final List<WorkoutRoutePoint> routePoints;
}

/// Parses GPX track data into a [WorkoutSession] and route points.
class GpxWorkoutParser {
  const GpxWorkoutParser();

  GpxParseResult parse(String gpxContent, {String sourceName = 'GPX import'}) {
    final document = XmlDocument.parse(gpxContent);
    final trackPoints = document.findAllElements('trkpt').toList();

    if (trackPoints.isEmpty) {
      throw const FormatException('GPX file contains no track points');
    }

    final routePoints = <WorkoutRoutePoint>[];
    DateTime? firstTime;
    DateTime? lastTime;

    for (final point in trackPoints) {
      final lat = double.tryParse(point.getAttribute('lat') ?? '');
      final lon = double.tryParse(point.getAttribute('lon') ?? '');
      if (lat == null || lon == null) continue;

      final timeText = point.getElement('time')?.innerText;
      final timestamp = timeText == null ? null : DateTime.tryParse(timeText);
      firstTime ??= timestamp;
      if (timestamp != null) {
        lastTime = timestamp;
      }

      routePoints.add(
        WorkoutRoutePoint(
          latitude: lat,
          longitude: lon,
          timestamp: timestamp,
        ),
      );
    }

    if (routePoints.isEmpty) {
      throw const FormatException('GPX file has no valid coordinates');
    }

    final start = firstTime ?? DateTime.now();
    final end = lastTime ?? start.add(const Duration(minutes: 30));
    final distanceMeters = routeDistanceMeters(routePoints);

    final workout = WorkoutSession(
      id: ImportedWorkoutIds.generate(),
      start: start,
      end: end.isAfter(start) ? end : start.add(const Duration(minutes: 1)),
      workoutType: 'running',
      distanceMeters: distanceMeters,
      sourceName: sourceName,
      startLatitude: routePoints.first.latitude,
      startLongitude: routePoints.first.longitude,
      endLatitude: routePoints.last.latitude,
      endLongitude: routePoints.last.longitude,
    );

    return GpxParseResult(workout: workout, routePoints: routePoints);
  }
}
