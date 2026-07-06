import 'package:flutter/material.dart';
import 'package:kynos/core/theme/theme.dart';

/// Subtle opacity pulse while assistant text is streaming.
class StreamingTextPulse extends StatefulWidget {
  const StreamingTextPulse({
    super.key,
    required this.isActive,
    required this.child,
  });

  final bool isActive;
  final Widget child;

  @override
  State<StreamingTextPulse> createState() => _StreamingTextPulseState();
}

class _StreamingTextPulseState extends State<StreamingTextPulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Motion.pulse,
    );
    _opacity = Tween<double>(begin: 0.85, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Motion.pulseCurve),
    );
    _syncAnimation();
  }

  @override
  void didUpdateWidget(StreamingTextPulse oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isActive != widget.isActive) {
      _syncAnimation();
    }
  }

  void _syncAnimation() {
    if (widget.isActive) {
      _controller.repeat(reverse: true);
    } else {
      _controller.stop();
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
      opacity: _opacity,
      child: widget.child,
    );
  }
}
