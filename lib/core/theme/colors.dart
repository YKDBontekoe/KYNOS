import 'package:flutter/material.dart';

/// KYNOS colour palette — iOS system colours, Apple Fitness aesthetic.
abstract final class KynosColors {
  // ── Fitness accents ─────────────────────────────────────────────────────
  /// Move / heart — Apple Fitness red
  static const Color move = Color(0xFFFF3B30);

  /// Exercise / HRV — Apple Fitness green
  static const Color exercise = Color(0xFF34C759);

  /// Stand / sleep — Apple Fitness blue
  static const Color stand = Color(0xFF007AFF);

  /// Energy / calories — Apple Fitness orange
  static const Color energy = Color(0xFFFF9F0A);

  /// System purple (readiness)
  static const Color purple = Color(0xFFAF52DE);

  /// Willpower / gold accent
  static const Color willpower = Color(0xFFFFD60A);

  // ── Neutral surfaces (light) ────────────────────────────────────────────
  /// iOS grouped background
  static const Color background = Color(0xFFF2F2F7);

  /// Card surface
  static const Color card = Colors.white;

  /// Primary label (black)
  static const Color label = Color(0xFF000000);

  /// Secondary label
  static const Color secondaryLabel = Color(0xFF8E8E93);

  /// Tertiary label / section header
  static const Color tertiaryLabel = Color(0xFFAEAEB2);

  /// Separator
  static const Color separator = Color(0xFFE5E5EA);

  // ── Neutral surfaces (dark) ─────────────────────────────────────────────
  static const Color backgroundDark = Color(0xFF000000);
  static const Color cardDark = Color(0xFF1C1C1E);
  static const Color labelDark = Color(0xFFFFFFFF);
  static const Color secondaryLabelDark = Color(0xFF8E8E93);
  static const Color tertiaryLabelDark = Color(0xFF636366);
  static const Color separatorDark = Color(0xFF38383A);

  // ── Navigation & glass ────────────────────────────────────────────────────
  static const Color navUnselected = Color(0xFF606060);

  /// White text/icons on saturated accent surfaces (hero banners).
  static const Color onAccent = Color(0xFFFFFFFF);

  static Color glassFillLight({double alpha = 0.65}) =>
      onAccent.withValues(alpha: alpha);

  static Color glassFillDark({double alpha = 0.07}) =>
      onAccent.withValues(alpha: alpha);

  static Color glassBorderLight({double alpha = 0.8}) =>
      onAccent.withValues(alpha: alpha);

  static Color glassBorderDark({double alpha = 0.12}) =>
      onAccent.withValues(alpha: alpha);

  static Color heroOrbOverlay({double alpha = 0.07}) =>
      onAccent.withValues(alpha: alpha);

  /// Maps a semantic colour key to the accent palette.
  static Color accentForKey(String key) => switch (key) {
        'move' => move,
        'exercise' => exercise,
        'stand' => stand,
        'energy' => energy,
        'purple' => purple,
        'willpower' => willpower,
        _ => stand,
      };
}
