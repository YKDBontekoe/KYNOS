import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kynos/core/theme/motion.dart';

/// Route transition presets for [GoRouter] [pageBuilder] callbacks.
abstract final class KynosPageTransitions {
  /// Standard push: fade + slight horizontal slide.
  static CustomTransitionPage<T> standard<T>({
    required LocalKey key,
    required Widget child,
  }) {
    return CustomTransitionPage<T>(
      key: key,
      child: child,
      transitionDuration: Motion.medium,
      reverseTransitionDuration: Motion.fast,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(parent: animation, curve: Motion.curve);
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.04, 0),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
    );
  }

  /// Modal-style: slide up from bottom with fade.
  static CustomTransitionPage<T> modalUp<T>({
    required LocalKey key,
    required Widget child,
  }) {
    return CustomTransitionPage<T>(
      key: key,
      child: child,
      transitionDuration: Motion.slow,
      reverseTransitionDuration: Motion.medium,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(parent: animation, curve: Motion.curve);
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.08),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
    );
  }

  /// Horizontal drill-down for nested settings-style routes.
  static CustomTransitionPage<T> horizontalDrill<T>({
    required LocalKey key,
    required Widget child,
  }) {
    return CustomTransitionPage<T>(
      key: key,
      child: child,
      transitionDuration: Motion.medium,
      reverseTransitionDuration: Motion.fast,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(parent: animation, curve: Motion.curve);
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        );
      },
    );
  }

  /// Cross-fade for auth / onboarding handoffs.
  static CustomTransitionPage<T> fadeThrough<T>({
    required LocalKey key,
    required Widget child,
  }) {
    return CustomTransitionPage<T>(
      key: key,
      child: child,
      transitionDuration: Motion.slow,
      reverseTransitionDuration: Motion.medium,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Motion.curve),
          child: child,
        );
      },
    );
  }
}
