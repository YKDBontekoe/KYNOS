import 'package:flutter/material.dart';
import 'package:kynos/core/theme/motion.dart';
import 'package:kynos/core/theme/spacing.dart' as tokens;

/// Linear progress bar with animated fill on appear and value change.
class AnimatedProgressBar extends StatelessWidget {
  const AnimatedProgressBar({
    super.key,
    required this.value,
    this.minHeight = 8,
    required this.backgroundColor,
    required this.valueColor,
    this.borderRadius = tokens.Radius.sm,
    this.duration = const Duration(milliseconds: 800),
  });

  final double value;
  final double minHeight;
  final Color backgroundColor;
  final Color valueColor;
  final double borderRadius;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: value.clamp(0.0, 1.0)),
        duration: duration,
        curve: Motion.curve,
        builder: (context, animatedValue, _) {
          return LinearProgressIndicator(
            value: animatedValue,
            minHeight: minHeight,
            backgroundColor: backgroundColor,
            valueColor: AlwaysStoppedAnimation(valueColor),
          );
        },
      ),
    );
  }
}
