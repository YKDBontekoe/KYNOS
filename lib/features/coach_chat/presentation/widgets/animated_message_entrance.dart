import 'package:flutter/material.dart';
import 'package:kynos/core/theme/motion.dart';

/// Slide + fade entrance for list items (e.g. chat bubbles).
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

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Motion.medium,
    );
    final curved = CurvedAnimation(parent: _controller, curve: Motion.curve);
    final begin = widget.fromRight ? const Offset(0.12, 0) : const Offset(-0.12, 0);
    _slide = Tween<Offset>(begin: begin, end: Offset.zero).animate(curved);
    _fade = curved;

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
        child: widget.child,
      ),
    );
  }
}
