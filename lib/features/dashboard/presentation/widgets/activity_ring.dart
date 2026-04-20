import 'dart:math' as math;
import 'package:flutter/material.dart';

class ActivityRing extends StatelessWidget {
  final double progress;
  final double size;
  final double strokeWidth;
  final List<Color> colors;

  const ActivityRing({
    super.key,
    required this.progress,
    required this.size,
    required this.strokeWidth,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(
          progress: progress,
          strokeWidth: strokeWidth,
          colors: colors,
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final List<Color> colors;

  const _RingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.colors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    for (var i = 0; i < colors.length; i++) {
      final spacing = strokeWidth * 0.28;
      final radius =
          (size.width / 2) - strokeWidth / 2 - (strokeWidth + spacing) * i;

      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..color = colors[i].withValues(alpha: 0.15),
      );

      if (progress > 0) {
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          -math.pi / 2,
          2 * math.pi * progress,
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
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}
