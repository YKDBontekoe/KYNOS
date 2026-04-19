import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:kynos/core/theme/spacing.dart' as tokens;

/// Liquid glass card — frosted blur + translucent surface + subtle border.
///
/// The blur effect mimics Apple's visionOS / iOS 18 glass material.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final double blurSigma;
  final Color? tintColor;
  final double borderRadius;
  final Border? border;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(tokens.Spacing.md),
    this.onTap,
    this.blurSigma = 20,
    this.tintColor,
    this.borderRadius = tokens.Radius.xl,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final glassFill = tintColor ??
        (isDark
            ? Colors.white.withValues(alpha: 0.07)
            : Colors.white.withValues(alpha: 0.65));

    final glassBorder = border ??
        Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.12)
              : Colors.white.withValues(alpha: 0.8),
        );

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              color: glassFill,
              borderRadius: BorderRadius.circular(borderRadius),
              border: glassBorder,
            ),
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}
