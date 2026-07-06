import 'package:flutter/material.dart';
import 'package:kynos/domain/entities/workout_route_point.dart';

/// Paints a fitted GPS route polyline with start and finish markers.
class RoutePolylinePainter extends CustomPainter {
  RoutePolylinePainter({
    required this.points,
    required this.lineColor,
    required this.startColor,
    required this.endColor,
    required this.gridColor,
    required this.markerBorderColor,
  });

  final List<WorkoutRoutePoint> points;
  final Color lineColor;
  final Color startColor;
  final Color endColor;
  final Color gridColor;
  final Color markerBorderColor;

  @override
  void paint(Canvas canvas, Size size) {
    _paintGrid(canvas, size);

    if (points.length < 2) {
      if (points.isNotEmpty) {
        _paintMarker(
          canvas,
          Offset(size.width / 2, size.height / 2),
          startColor,
        );
      }
      return;
    }

    final bounds = _Bounds.fromPoints(points);
    final path = Path();
    Offset? firstOffset;

    for (var i = 0; i < points.length; i++) {
      final offset = _toOffset(points[i], bounds, size);
      if (i == 0) {
        path.moveTo(offset.dx, offset.dy);
        firstOffset = offset;
      } else {
        path.lineTo(offset.dx, offset.dy);
      }
    }

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, linePaint);

    if (firstOffset != null) {
      _paintMarker(canvas, firstOffset, startColor);
    }
    _paintMarker(
      canvas,
      _toOffset(points.last, bounds, size),
      endColor,
    );
  }

  void _paintGrid(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;

    const divisions = 4;
    for (var i = 1; i < divisions; i++) {
      final dx = size.width * i / divisions;
      final dy = size.height * i / divisions;
      canvas.drawLine(Offset(dx, 0), Offset(dx, size.height), paint);
      canvas.drawLine(Offset(0, dy), Offset(size.width, dy), paint);
    }
  }

  void _paintMarker(Canvas canvas, Offset center, Color color) {
    canvas.drawCircle(
      center,
      7,
      Paint()
        ..color = color
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      center,
      7,
      Paint()
        ..color = markerBorderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  Offset _toOffset(WorkoutRoutePoint point, _Bounds bounds, Size size) {
    const padding = 20.0;
    final width = size.width - padding * 2;
    final height = size.height - padding * 2;
    final x = bounds.lonRange == 0
        ? 0.5
        : (point.longitude - bounds.minLon) / bounds.lonRange;
    final y = bounds.latRange == 0
        ? 0.5
        : (point.latitude - bounds.minLat) / bounds.latRange;
    return Offset(padding + x * width, padding + (1 - y) * height);
  }

  @override
  bool shouldRepaint(covariant RoutePolylinePainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.startColor != startColor ||
        oldDelegate.endColor != endColor ||
        oldDelegate.markerBorderColor != markerBorderColor;
  }
}

class _Bounds {
  const _Bounds({
    required this.minLat,
    required this.maxLat,
    required this.minLon,
    required this.maxLon,
  });

  factory _Bounds.fromPoints(List<WorkoutRoutePoint> points) {
    var minLat = points.first.latitude;
    var maxLat = points.first.latitude;
    var minLon = points.first.longitude;
    var maxLon = points.first.longitude;

    for (final point in points) {
      minLat = minLat < point.latitude ? minLat : point.latitude;
      maxLat = maxLat > point.latitude ? maxLat : point.latitude;
      minLon = minLon < point.longitude ? minLon : point.longitude;
      maxLon = maxLon > point.longitude ? maxLon : point.longitude;
    }

    const epsilon = 0.0001;
    if ((maxLat - minLat).abs() < epsilon) {
      minLat -= epsilon;
      maxLat += epsilon;
    }
    if ((maxLon - minLon).abs() < epsilon) {
      minLon -= epsilon;
      maxLon += epsilon;
    }

    return _Bounds(
      minLat: minLat,
      maxLat: maxLat,
      minLon: minLon,
      maxLon: maxLon,
    );
  }

  final double minLat;
  final double maxLat;
  final double minLon;
  final double maxLon;

  double get latRange => maxLat - minLat;
  double get lonRange => maxLon - minLon;
}
