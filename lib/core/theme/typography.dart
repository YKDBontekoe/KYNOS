import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kynos/core/theme/colors.dart';

/// Named text styles for the KYNOS design system.
abstract final class KynosTypography {
  static TextTheme textTheme({required Brightness brightness}) {
    final labelColor =
        brightness == Brightness.dark ? KynosColors.labelDark : KynosColors.label;
    final secondaryColor = brightness == Brightness.dark
        ? KynosColors.secondaryLabelDark
        : KynosColors.secondaryLabel;
    final tertiaryColor = brightness == Brightness.dark
        ? KynosColors.tertiaryLabelDark
        : KynosColors.tertiaryLabel;

    return TextTheme(
      displayLarge: GoogleFonts.dmMono(
        fontSize: 48,
        fontWeight: FontWeight.w700,
        color: labelColor,
        height: 1,
        letterSpacing: -2,
      ),
      displayMedium: GoogleFonts.inter(
        fontSize: 36,
        fontWeight: FontWeight.w800,
        color: labelColor,
        height: 1,
        letterSpacing: -1.5,
      ),
      displaySmall: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w800,
        color: labelColor,
        height: 1.1,
        letterSpacing: -0.8,
      ),
      titleLarge: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: labelColor,
        letterSpacing: -0.4,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: labelColor,
        letterSpacing: -0.2,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: secondaryColor,
        height: 1.4,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: secondaryColor,
        height: 1.4,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: secondaryColor,
        letterSpacing: 0.2,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: secondaryColor,
        letterSpacing: 0.5,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
        color: tertiaryColor,
      ),
    );
  }

  /// Uppercase section label (e.g. "HEALTH METRICS").
  static TextStyle sectionLabel(Brightness brightness) => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: brightness == Brightness.dark
            ? KynosColors.secondaryLabelDark
            : KynosColors.secondaryLabel,
        letterSpacing: 0.5,
      );

  /// Large numeric metric value — DM Mono.
  static TextStyle metricValue(Brightness brightness) => GoogleFonts.dmMono(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color:
            brightness == Brightness.dark ? KynosColors.labelDark : KynosColors.label,
        height: 1,
        letterSpacing: -1,
      );

  /// Hero banner title (e.g. "TRAINING").
  static TextStyle heroTitle() => GoogleFonts.inter(
        fontSize: 34,
        fontWeight: FontWeight.w900,
        color: KynosColors.onAccent,
        letterSpacing: -1,
        height: 1,
      );

  /// Hero banner subtitle.
  static TextStyle heroSubtitle() => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: KynosColors.onAccent.withValues(alpha: 0.70),
        letterSpacing: 0.2,
      );

  /// Filled button label.
  static TextStyle buttonLabel() => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
        color: KynosColors.onAccent,
      );

  /// Compact chip / badge label.
  static TextStyle chipLabel(Brightness brightness) => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: brightness == Brightness.dark
            ? KynosColors.secondaryLabelDark
            : KynosColors.secondaryLabel,
      );

  /// Nav bar item label.
  static TextStyle navLabel({
    required bool selected,
    required Color color,
  }) =>
      GoogleFonts.inter(
        fontSize: 10,
        fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
        color: color,
        letterSpacing: selected ? -0.2 : 0.1,
      );
}
