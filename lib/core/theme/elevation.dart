import 'package:flutter/material.dart';

/// Shadow presets for the KYNOS design system.
///
/// Apple's cards read as "floating" because of two stacked shadows — a
/// wide, very soft ambient shadow plus a tight, barely-visible contact
/// shadow close to the surface. A single hard shadow looks flat by
/// comparison, so card surfaces use both layers below.
abstract final class KynosElevation {
  static List<BoxShadow> cardSubtle(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: isDark ? 0.32 : 0.06),
        blurRadius: 24,
        offset: const Offset(0, 10),
      ),
      BoxShadow(
        color: Colors.black.withValues(alpha: isDark ? 0.24 : 0.035),
        blurRadius: 2,
        offset: const Offset(0, 1),
      ),
    ];
  }

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
