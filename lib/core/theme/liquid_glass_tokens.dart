import 'dart:ui';

import 'package:flutter/material.dart';

/// Design tokens for Apple Liquid Glass materials — blur, vibrancy, specular edges.
abstract final class LiquidGlassTokens {
  static const double navBlurSigma = 48;
  static const double surfaceBlurSigma = 24;
  static const double buttonBlurSigma = 20;
  static const double indicatorBlurSigma = 16;

  /// Subtle saturation boost mimicking iOS vibrancy behind frosted glass.
  static const ColorFilter vibrancyFilter = ColorFilter.matrix(<double>[
    1.12, 0, 0, 0, 0,
    0, 1.12, 0, 0, 0,
    0, 0, 1.12, 0, 0,
    0, 0, 0, 1, 0,
  ]);

  static ImageFilter blur(double sigma) =>
      ImageFilter.blur(sigmaX: sigma, sigmaY: sigma);

  static List<Color> fillGradient(Brightness brightness, {bool onAccent = false}) {
    if (onAccent) {
      return [
        Colors.white.withValues(alpha: 0.28),
        Colors.white.withValues(alpha: 0.12),
      ];
    }
    return brightness == Brightness.dark
        ? [
            Colors.white.withValues(alpha: 0.14),
            Colors.white.withValues(alpha: 0.05),
          ]
        : [
            Colors.white.withValues(alpha: 0.72),
            Colors.white.withValues(alpha: 0.45),
          ];
  }

  static Color borderColor(Brightness brightness, {bool onAccent = false}) {
    if (onAccent) return Colors.white.withValues(alpha: 0.45);
    return brightness == Brightness.dark
        ? Colors.white.withValues(alpha: 0.18)
        : Colors.white.withValues(alpha: 0.85);
  }

  static Color specularHighlight(Brightness brightness, {bool onAccent = false}) {
    if (onAccent) return Colors.white.withValues(alpha: 0.55);
    return brightness == Brightness.dark
        ? Colors.white.withValues(alpha: 0.22)
        : Colors.white.withValues(alpha: 0.90);
  }
}
