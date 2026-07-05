import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Concentric activity rings with per-ring progress arcs.
class ActivityRing extends StatelessWidget {
  const ActivityRing({
    super.key,
    this.progress,
    this.ringProgresses,
    required this.size,
    required this.strokeWidth,
    required this.colors,
  });

  /// Legacy single progress applied to every ring when [ringProgresses] is null.
  final double? progress;

  /// Per-ring progress values (0–1), outer ring first.
  final List<double>? ringProgresses;
  final double size;
  final double strokeWidth;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    final progresses = ringProgresses ??
        List<double>.filled(colors.length, progress ?? 0);

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: RingPainter(
          ringProgresses: progresses,
          strokeWidth: strokeWidth,
          colors: colors,
        ),
      ),
    );
  }
}

class RingPainter extends CustomPainter {
  const RingPainter({
    required this.ringProgresses,
    required this.strokeWidth,
    required this.colors,
  });

  final List<double> ringProgresses;
  final double strokeWidth;
  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    for (var i = 0; i < colors.length; i++) {
      final spacing = strokeWidth * 0.28;
      final radius =
          (size.width / 2) - strokeWidth / 2 - (strokeWidth + spacing) * i;
      final ringProgress = i < ringProgresses.length ? ringProgresses[i] : 0;

      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..color = colors[i].withValues(alpha: 0.15),
      );

      if (ringProgress > 0) {
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          -math.pi / 2,
          2 * math.pi * ringProgress,
          false,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = strokeWidth
            ..color = colors[i]
            ..strokeCap = StrokeCap.round,
        );
      }
    }
  }

  @override
  bool shouldRepaint(RingPainter old) =>
      !listEquals(old.ringProgresses, ringProgresses) ||
      old.strokeWidth != strokeWidth ||
      old.colors != colors;
}
