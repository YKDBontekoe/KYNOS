import 'dart:math' as math;

import 'package:kynos/domain/entities/workout_route_point.dart';

/// Haversine distance between two WGS-84 coordinates in meters.
double haversineMeters(
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

/// Total route length from consecutive GPS points.
double routeDistanceMeters(List<WorkoutRoutePoint> points) {
  if (points.length < 2) return 0;

  var total = 0.0;
  for (var i = 1; i < points.length; i++) {
    total += haversineMeters(
      points[i - 1].latitude,
      points[i - 1].longitude,
      points[i].latitude,
      points[i].longitude,
    );
  }
  return total;
}

double _toRadians(double degrees) => degrees * math.pi / 180;
