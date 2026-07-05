import 'package:flutter/material.dart';
import 'package:kynos/core/theme/spacing.dart' as tokens;
import 'package:kynos/shared/widgets/liquid_glass_surface.dart';

/// Liquid glass card — frosted blur + translucent surface + specular edge.
///
/// Wraps [LiquidGlassSurface] for coach bubbles, input bars, and floating nav.
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
    final surface = LiquidGlassSurface(
      borderRadius: borderRadius,
      blurSigma: blurSigma,
      padding: padding,
      tintColor: tintColor,
      border: border,
      child: child,
    );

    if (onTap == null) return surface;

    return GestureDetector(onTap: onTap, child: surface);
  }
}
