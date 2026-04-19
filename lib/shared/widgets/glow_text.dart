import 'package:flutter/material.dart';

/// Text with a soft glow — used for brand wordmark and key numbers.
class GlowText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final Color? glowColor;
  final double blurRadius;
  final int shadowLayers;

  const GlowText(
    this.text, {
    super.key,
    this.style,
    this.glowColor,
    this.blurRadius = 16,
    this.shadowLayers = 3,
  });

  @override
  Widget build(BuildContext context) {
    final baseStyle = style ?? DefaultTextStyle.of(context).style;
    final glow = glowColor ?? (baseStyle.color ?? Colors.white);

    return Text(
      text,
      style: baseStyle.copyWith(
        shadows: List.generate(
          shadowLayers,
          (_) => Shadow(
            color: glow.withValues(alpha: 0.6),
            blurRadius: blurRadius,
          ),
        ),
      ),
    );
  }
}
