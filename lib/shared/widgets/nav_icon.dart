import 'package:flutter/material.dart';

/// Lucide-style SVG path icons for bottom navigation.
abstract final class NavIconPaths {
  static const home =
      'M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z M9 22V12h6v10';
  static const activity = 'M22 12H18L15 21 9 3 6 12H2';
  static const character =
      'M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z';
}

/// Paints a stroke SVG path for navigation icons (24×24 viewBox).
class NavIconPainter extends CustomPainter {
  const NavIconPainter({
    required this.pathData,
    required this.color,
    required this.strokeWidth,
  });

  final String pathData;
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 24.0;
    canvas.scale(scale, scale);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth / scale
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final pathData = parseSvgPath(this.pathData);
    canvas.drawPath(pathData, paint);
  }

  @override
  bool shouldRepaint(NavIconPainter old) =>
      old.pathData != pathData ||
      old.color != color ||
      old.strokeWidth != strokeWidth;

  /// Minimal SVG path parser for Lucide stroke icons.
  static Path parseSvgPath(String d) {
    final path = Path();
    final tokens = RegExp(
      r'[MLHVCSQTAZmlhvcsqtaz]|[-+]?(?:\d+\.?\d*|\.\d+)(?:[eE][-+]?\d+)?',
    ).allMatches(d).map((m) => m.group(0)!).toList();

    var i = 0;
    double cx = 0, cy = 0;
    double? lastCubicCtrlX;
    double? lastCubicCtrlY;
    String cmd = 'M';

    double next() => double.parse(tokens[i++]);

    void recordCubicCtrl(double x2, double y2) {
      lastCubicCtrlX = x2;
      lastCubicCtrlY = y2;
    }

    while (i < tokens.length) {
      final t = tokens[i];
      if (RegExp(r'^[A-Za-z]$').hasMatch(t)) {
        cmd = t;
        i++;
      }
      switch (cmd) {
        case 'M':
          cx = next();
          cy = next();
          path.moveTo(cx, cy);
          cmd = 'L';
        case 'L':
          cx = next();
          cy = next();
          path.lineTo(cx, cy);
        case 'H':
          cx = next();
          path.lineTo(cx, cy);
        case 'V':
          cy = next();
          path.lineTo(cx, cy);
        case 'C':
          final x1 = next(), y1 = next();
          final x2 = next(), y2 = next();
          cx = next();
          cy = next();
          path.cubicTo(x1, y1, x2, y2, cx, cy);
          recordCubicCtrl(x2, y2);
        case 'S':
          final x2 = next(), y2 = next();
          final ex = next(), ey = next();
          final x1 = lastCubicCtrlX != null ? 2 * cx - lastCubicCtrlX! : cx;
          final y1 = lastCubicCtrlY != null ? 2 * cy - lastCubicCtrlY! : cy;
          path.cubicTo(x1, y1, x2, y2, ex, ey);
          recordCubicCtrl(x2, y2);
          cx = ex;
          cy = ey;
        case 'Q':
          final x1 = next(), y1 = next();
          cx = next();
          cy = next();
          path.quadraticBezierTo(x1, y1, cx, cy);
        case 'A':
          final rx = next(), ry = next();
          final rot = next();
          final largeArc = next() == 1;
          final sweep = next() == 1;
          cx = next();
          cy = next();
          path.arcToPoint(
            Offset(cx, cy),
            radius: Radius.elliptical(rx, ry),
            rotation: rot,
            largeArc: largeArc,
            clockwise: sweep,
          );
        case 'Z':
        case 'z':
          path.close();
        case 'l':
          cx += next();
          cy += next();
          path.lineTo(cx, cy);
        case 'm':
          cx += next();
          cy += next();
          path.moveTo(cx, cy);
          cmd = 'l';
        case 'h':
          cx += next();
          path.lineTo(cx, cy);
        case 'v':
          cy += next();
          path.lineTo(cx, cy);
        case 'c':
          final dx1 = next(), dy1 = next();
          final dx2 = next(), dy2 = next();
          final dx = next(), dy = next();
          final x2 = cx + dx2;
          final y2 = cy + dy2;
          path.cubicTo(
            cx + dx1,
            cy + dy1,
            x2,
            y2,
            cx + dx,
            cy + dy,
          );
          cx += dx;
          cy += dy;
          recordCubicCtrl(x2, y2);
        case 's':
          final dx2 = next(), dy2 = next();
          final dx = next(), dy = next();
          final x1 = lastCubicCtrlX != null ? 2 * cx - lastCubicCtrlX! : cx;
          final y1 = lastCubicCtrlY != null ? 2 * cy - lastCubicCtrlY! : cy;
          final x2 = cx + dx2;
          final y2 = cy + dy2;
          cx += dx;
          cy += dy;
          path.cubicTo(x1, y1, x2, y2, cx, cy);
          recordCubicCtrl(x2, y2);
        case 'a':
          final rx = next(), ry = next();
          final rot = next();
          final largeArc = next() == 1;
          final sweep = next() == 1;
          final ex = cx + next(), ey = cy + next();
          path.arcToPoint(
            Offset(ex, ey),
            radius: Radius.elliptical(rx, ry),
            rotation: rot,
            largeArc: largeArc,
            clockwise: sweep,
          );
          cx = ex;
          cy = ey;
        default:
          i++;
      }
    }
    return path;
  }
}