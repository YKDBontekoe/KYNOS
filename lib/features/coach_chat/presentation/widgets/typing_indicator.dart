import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:kynos/core/theme/theme.dart';

class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (i) => Padding(
          padding: EdgeInsets.only(left: i > 0 ? 6 : 0),
          child: Opacity(
            opacity: 0.25 +
                0.75 *
                    math
                        .sin((_controller.value + i / 3.0) % 1.0 * math.pi)
                        .clamp(0.0, 1.0),
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppTheme.secondaryLabel,
                shape: BoxShape.circle,
              ),
            ),
          ),
        )),
      ),
    );
  }
}
