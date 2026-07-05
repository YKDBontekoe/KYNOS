import 'package:flutter/material.dart';

class CharacterShieldPainter extends CustomPainter {
  const CharacterShieldPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 24.0;
    canvas.scale(scale, scale);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0 / scale
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()
      ..moveTo(12, 22)
      ..cubicTo(12, 22, 4, 18, 4, 12)
      ..lineTo(4, 6)
      ..lineTo(12, 2)
      ..lineTo(20, 6)
      ..lineTo(20, 12)
      ..cubicTo(20, 18, 12, 22, 12, 22)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CharacterShieldPainter old) => old.color != color;
}
