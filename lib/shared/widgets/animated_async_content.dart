import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kynos/core/theme/motion.dart';

/// Cross-fades between [AsyncValue] states instead of jump-cutting.
class AnimatedAsyncContent<T> extends StatelessWidget {
  const AnimatedAsyncContent({
    super.key,
    required this.value,
    required this.loading,
    required this.error,
    required this.data,
  });

  final AsyncValue<T> value;
  final WidgetBuilder loading;
  final Widget Function(BuildContext context, Object error, StackTrace stackTrace)
      error;
  final Widget Function(BuildContext context, T data) data;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: Motion.fast,
      switchInCurve: Motion.curve,
      switchOutCurve: Motion.curveIn,
      child: value.when(
        loading: () => KeyedSubtree(
          key: const ValueKey<String>('loading'),
          child: loading(context),
        ),
        error: (err, stack) => KeyedSubtree(
          key: ValueKey<String>('error-$err'),
          child: error(context, err, stack),
        ),
        data: (item) => KeyedSubtree(
          key: const ValueKey<String>('data'),
          child: data(context, item),
        ),
      ),
    );
  }
}

/// Fades content in on first mount — for sync widgets that appear conditionally.
class FadeInOnAppear extends StatefulWidget {
  const FadeInOnAppear({
    super.key,
    required this.child,
    this.duration = Motion.medium,
  });

  final Widget child;
  final Duration duration;

  @override
  State<FadeInOnAppear> createState() => _FadeInOnAppearState();
}

class _FadeInOnAppearState extends State<FadeInOnAppear>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: _controller, curve: Motion.curve),
      child: widget.child,
    );
  }
}
