import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kynos/core/theme/motion.dart';

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

  List<double> get _resolvedProgresses =>
      ringProgresses ?? List<double>.filled(colors.length, progress ?? 0);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: ringSemanticsLabel(_resolvedProgresses),
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: RingPainter(
            ringProgresses: _resolvedProgresses,
            strokeWidth: strokeWidth,
            colors: colors,
          ),
        ),
      ),
    );
  }
}

/// Accessibility label for activity ring progress values.
String ringSemanticsLabel(List<double> progresses) {
  final parts = <String>[];
  for (var i = 0; i < progresses.length; i++) {
    final pct = (progresses[i] * 100).round();
    parts.add('Ring ${i + 1} $pct percent');
  }
  return parts.isEmpty ? 'Activity rings' : 'Activity rings: ${parts.join(', ')}';
}

/// [ActivityRing] with staggered sweep-in animation on appear and data refresh.
class AnimatedActivityRing extends StatefulWidget {
  const AnimatedActivityRing({
    super.key,
    this.progress,
    this.ringProgresses,
    required this.size,
    required this.strokeWidth,
    required this.colors,
  });

  final double? progress;
  final List<double>? ringProgresses;
  final double size;
  final double strokeWidth;
  final List<Color> colors;

  @override
  State<AnimatedActivityRing> createState() => _AnimatedActivityRingState();
}

class _AnimatedActivityRingState extends State<AnimatedActivityRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  List<double> get _targetProgresses =>
      widget.ringProgresses ??
      List<double>.filled(widget.colors.length, widget.progress ?? 0);

  bool _progressesChanged(List<double> previous, List<double> current) {
    if (previous.length != current.length) return true;
    const epsilon = 0.001;
    for (var i = 0; i < previous.length; i++) {
      if ((previous[i] - current[i]).abs() > epsilon) return true;
    }
    return false;
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Motion.ringSweep,
    )..forward();
  }

  @override
  void didUpdateWidget(AnimatedActivityRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldTargets = oldWidget.ringProgresses ??
        List<double>.filled(
          oldWidget.colors.length,
          oldWidget.progress ?? 0,
        );
    if (_progressesChanged(oldTargets, _targetProgresses)) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<double> _animatedProgresses() {
    final count = _targetProgresses.length;
    if (count == 0) return const [];

    final staggerFraction =
        Motion.ringStagger.inMilliseconds / Motion.ringSweep.inMilliseconds;

    return List<double>.generate(count, (i) {
      final start = (i * staggerFraction).clamp(0.0, 0.85);
      final interval = Interval(start, 1, curve: Motion.curve);
      return interval.transform(_controller.value) * _targetProgresses[i];
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final progresses = _animatedProgresses();
        return Semantics(
          label: ringSemanticsLabel(_targetProgresses),
          child: SizedBox(
            width: widget.size,
            height: widget.size,
            child: CustomPaint(
              painter: RingPainter(
                ringProgresses: progresses,
                strokeWidth: widget.strokeWidth,
                colors: widget.colors,
              ),
            ),
          ),
        );
      },
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
