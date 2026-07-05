import 'package:flutter/material.dart';
import 'package:kynos/core/theme/liquid_glass_tokens.dart';

/// Apple Liquid Glass surface — vibrancy, frosted blur, specular edge highlight.
class LiquidGlassSurface extends StatelessWidget {
  const LiquidGlassSurface({
    super.key,
    required this.child,
    this.borderRadius = 24,
    this.blurSigma = LiquidGlassTokens.surfaceBlurSigma,
    this.padding = EdgeInsets.zero,
    this.onAccent = false,
    this.tintColor,
    this.border,
    this.applyVibrancy = true,
  });

  final Widget child;
  final double borderRadius;
  final double blurSigma;
  final EdgeInsetsGeometry padding;
  final bool onAccent;
  final Color? tintColor;
  final Border? border;
  final bool applyVibrancy;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final radius = BorderRadius.circular(borderRadius);
    final gradientColors = LiquidGlassTokens.fillGradient(
      brightness,
      onAccent: onAccent,
    );

    Widget surface = ClipRRect(
      borderRadius: radius,
      child: Stack(
        children: [
          Positioned.fill(
            child: BackdropFilter(
              filter: LiquidGlassTokens.blur(blurSigma),
              child: const ColoredBox(color: Colors.transparent),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: radius,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: tintColor != null
                    ? [
                        tintColor!,
                        tintColor!.withValues(alpha: 0.55),
                      ]
                    : gradientColors,
              ),
              border: border ??
                  Border.all(
                    color: LiquidGlassTokens.borderColor(
                      brightness,
                      onAccent: onAccent,
                    ),
                    width: 0.5,
                  ),
            ),
            child: Padding(padding: padding, child: child),
          ),
          Positioned(
            top: 0,
            left: borderRadius * 0.25,
            right: borderRadius * 0.25,
            height: 1,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    LiquidGlassTokens.specularHighlight(
                      brightness,
                      onAccent: onAccent,
                    ),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );

    if (applyVibrancy) {
      surface = ColorFiltered(
        colorFilter: LiquidGlassTokens.vibrancyFilter,
        child: surface,
      );
    }

    return surface;
  }
}
