import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// KYNOS design system — iOS system colour palette, Apple Fitness aesthetic.
class AppTheme {
  AppTheme._();

  // ── iOS system colours ────────────────────────────────────────────────────
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

  // ── Neutral surfaces ─────────────────────────────────────────────────────
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

  // ── System UI ─────────────────────────────────────────────────────────────
  static const SystemUiOverlayStyle lightOverlay = SystemUiOverlayStyle(
    statusBarBrightness: Brightness.light,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: background,
  );

  // ── Theme ─────────────────────────────────────────────────────────────────
  static ThemeData get light => ThemeData(
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: stand,
      secondary: exercise,
      error: move,
      surface: card,
      onSurface: label,
    ),
    scaffoldBackgroundColor: background,
    textTheme: _textTheme(),
    cardTheme: CardThemeData(
      color: card,
      elevation: 0,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: stand,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(54),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
        ),
        textStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.1,
        ),
      ),
    ),
    dividerTheme: const DividerThemeData(color: separator, thickness: 0.5),
    splashFactory: InkRipple.splashFactory,
  );

  static TextTheme _textTheme() => TextTheme(
    // Big metric numbers — DM Mono
    displayLarge: GoogleFonts.dmMono(
      fontSize: 48,
      fontWeight: FontWeight.w700,
      color: label,
      height: 1,
      letterSpacing: -2,
    ),
    // Section hero number
    displayMedium: GoogleFonts.inter(
      fontSize: 36,
      fontWeight: FontWeight.w800,
      color: label,
      height: 1,
      letterSpacing: -1.5,
    ),
    // Page title / card heading
    displaySmall: GoogleFonts.inter(
      fontSize: 24,
      fontWeight: FontWeight.w800,
      color: label,
      height: 1.1,
      letterSpacing: -0.8,
    ),
    titleLarge: GoogleFonts.inter(
      fontSize: 18,
      fontWeight: FontWeight.w700,
      color: label,
      letterSpacing: -0.4,
    ),
    titleMedium: GoogleFonts.inter(
      fontSize: 15,
      fontWeight: FontWeight.w600,
      color: label,
      letterSpacing: -0.2,
    ),
    bodyLarge: GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: secondaryLabel,
      height: 1.4,
    ),
    bodyMedium: GoogleFonts.inter(
      fontSize: 13,
      fontWeight: FontWeight.w400,
      color: secondaryLabel,
      height: 1.4,
    ),
    labelLarge: GoogleFonts.inter(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: secondaryLabel,
      letterSpacing: 0.2,
    ),
    labelSmall: GoogleFonts.inter(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.8,
      color: tertiaryLabel,
    ),
  );
}
