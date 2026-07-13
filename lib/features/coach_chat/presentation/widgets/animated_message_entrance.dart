import 'package:flutter/material.dart';
import 'package:kynos/core/theme/motion.dart';

/// Slide + fade + scale entrance for list items (e.g. chat bubbles).
class AnimatedMessageEntrance extends StatefulWidget {
  const AnimatedMessageEntrance({
    super.key,
    required this.fromRight,
    required this.animate,
    required this.child,
  });

  final bool fromRight;
  final bool animate;
  final Widget child;

  @override
  State<AnimatedMessageEntrance> createState() =>
      _AnimatedMessageEntranceState();
}

class _AnimatedMessageEntranceState extends State<AnimatedMessageEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Motion.slow,
    );
    final slideCurved = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 0.85, curve: Curves.easeOutCubic),
    );
    final scaleCurved = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );
    final begin = widget.fromRight
        ? const Offset(0.08, 0.04)
        : const Offset(-0.08, 0.04);
    _slide = Tween<Offset>(begin: begin, end: Offset.zero).animate(slideCurved);
    _fade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 0.6, curve: Curves.easeOut),
    );
    _scale = Tween<double>(begin: 0.94, end: 1).animate(scaleCurved);

    if (widget.animate) {
      _controller.forward();
    } else {
      _controller.value = 1;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: ScaleTransition(
          scale: _scale,
          alignment: widget.fromRight
              ? Alignment.centerRight
              : Alignment.centerLeft,
          child: widget.child,
        ),
      ),
    );
  }
}
