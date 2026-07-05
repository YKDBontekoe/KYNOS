import 'package:flutter/material.dart';

/// Lucide-style SVG path icons for bottom navigation.
abstract final class NavIconPaths {
  /// Daily dashboard — four-panel grid.
  static const today = NavIconDefinition(
    outline:
        'M3 3h7v9H3z M14 3h7v5h-7z M14 12h7v9h-7z M3 16h7v5H3z',
    filled:
        'M3 3h7v9H3z M14 3h7v5h-7z M14 12h7v9h-7z M3 16h7v5H3z',
  );

  /// Running route — winding path with finish pin.
  static const training = NavIconDefinition(
    outline:
        'M4 15s1-1 4-1 5 2 8 2 4-1 4-1V3s-1 1-4 1-5-2-8-2-4 1-4 1z M4 22v-7',
    filled:
        'M4 15s1-1 4-1 5 2 8 2 4-1 4-1V3s-1 1-4 1-5-2-8-2-4 1-4 1z M4 22v-7',
  );

  /// RPG character — heraldic shield.
  static const character = NavIconDefinition(
    outline: 'M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z',
    filled: 'M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z',
  );

  // Legacy aliases kept for tests and gradual migration.
  static const home = today;
  static const activity = training;
}

/// Outline and filled SVG paths for a single nav icon.
@immutable
class NavIconDefinition {
  const NavIconDefinition({
    required this.outline,
    String? filled,
  }) : filled = filled ?? outline;

  final String outline;
  final String filled;
}

/// Paints a stroke or filled SVG path for navigation icons (24×24 viewBox).
class NavIconPainter extends CustomPainter {
  const NavIconPainter({
    required this.pathData,
    required this.color,
    required this.strokeWidth,
    this.filled = false,
  });

  final String pathData;
  final Color color;
  final double strokeWidth;
  final bool filled;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 24.0;
    canvas.scale(scale, scale);

    final path = parseSvgPath(pathData);

    if (filled) {
      final fillPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;
      canvas.drawPath(path, fillPaint);

      final strokePaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5 / scale
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      canvas.drawPath(path, strokePaint);
      return;
    }

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth / scale
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(NavIconPainter old) =>
      old.pathData != pathData ||
      old.color != color ||
      old.strokeWidth != strokeWidth ||
      old.filled != filled;

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
