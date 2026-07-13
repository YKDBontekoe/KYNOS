import 'package:flutter/material.dart';
import 'package:kynos/core/theme/theme.dart';

/// Three-dot "coach is thinking" indicator with a staggered bounce.
class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final kynos = context.kynosTheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.sm,
        vertical: Spacing.xs,
      ),
      decoration: BoxDecoration(
        color: kynos.purple.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(Radius.full),
      ),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final delay = i * 0.16;
            final progress = ((_controller.value - delay) % 1.0 + 1.0) % 1.0;
            final bounce = Curves.easeInOutSine.transform(
              (progress < 0.5 ? progress : 1 - progress) * 2,
            );
            return Padding(
              padding: EdgeInsets.only(left: i > 0 ? 5 : 0),
              child: Transform.translate(
                offset: Offset(0, -3 * bounce),
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: Color.lerp(kynos.purple, kynos.stand, bounce * 0.5),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
