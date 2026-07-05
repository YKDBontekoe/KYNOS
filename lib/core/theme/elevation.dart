import 'package:flutter/material.dart';

/// Shadow presets for the KYNOS design system.
abstract final class KynosElevation {
  static List<BoxShadow> cardSubtle(Brightness brightness) => [
        BoxShadow(
          color: Colors.black.withValues(
            alpha: brightness == Brightness.dark ? 0.3 : 0.05,
          ),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> metricTile(Brightness brightness) => cardSubtle(brightness);

  static List<BoxShadow> navBar(Brightness brightness) => [
        BoxShadow(
          color: Colors.black.withValues(
            alpha: brightness == Brightness.dark ? 0.4 : 0.18,
          ),
          blurRadius: 48,
          offset: const Offset(0, 16),
        ),
        BoxShadow(
          color: Colors.black.withValues(
            alpha: brightness == Brightness.dark ? 0.2 : 0.08,
          ),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];
}
