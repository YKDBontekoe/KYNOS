import 'dart:math' as math;

import 'package:kynos/core/constants/imported_workout_ids.dart';
import 'package:kynos/domain/entities/workout_route_point.dart';
import 'package:kynos/domain/entities/workout_session.dart';
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
    final distanceMeters = _haversineDistance(routePoints);

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

  double _haversineDistance(List<WorkoutRoutePoint> points) {
    if (points.length < 2) return 0;

    var total = 0.0;
    for (var i = 1; i < points.length; i++) {
      total += _segmentMeters(
        points[i - 1].latitude,
        points[i - 1].longitude,
        points[i].latitude,
        points[i].longitude,
      );
    }
    return total;
  }

  double _segmentMeters(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadius = 6371000.0;
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) *
            math.cos(_toRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }

  double _toRadians(double degrees) => degrees * math.pi / 180;
}
