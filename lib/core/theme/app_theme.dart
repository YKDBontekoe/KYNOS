import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kynos/core/theme/colors.dart';
import 'package:kynos/core/theme/kynos_theme_extension.dart';
import 'package:kynos/core/theme/spacing.dart' as tokens;
import 'package:kynos/core/theme/typography.dart';

/// KYNOS design system — iOS system colour palette, Apple Fitness aesthetic.
class AppTheme {
  AppTheme._();

  // ── Colour aliases (backward compatible) ──────────────────────────────────
  static const Color move = KynosColors.move;
  static const Color exercise = KynosColors.exercise;
  static const Color stand = KynosColors.stand;
  static const Color energy = KynosColors.energy;
  static const Color purple = KynosColors.purple;
  static const Color willpower = KynosColors.willpower;
  static const Color background = KynosColors.background;
  static const Color card = KynosColors.card;
  static const Color label = KynosColors.label;
  static const Color secondaryLabel = KynosColors.secondaryLabel;
  static const Color tertiaryLabel = KynosColors.tertiaryLabel;
  static const Color separator = KynosColors.separator;
  static const Color navUnselected = KynosColors.navUnselected;

  // ── System UI ─────────────────────────────────────────────────────────────
  static const SystemUiOverlayStyle lightOverlay = SystemUiOverlayStyle(
    statusBarBrightness: Brightness.light,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: background,
  );

  static const SystemUiOverlayStyle darkOverlay = SystemUiOverlayStyle(
    statusBarBrightness: Brightness.dark,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: KynosColors.backgroundDark,
  );

  // ── Theme ─────────────────────────────────────────────────────────────────
  static ThemeData get light => _buildTheme(
        brightness: Brightness.light,
        extension: KynosThemeExtension.light,
        overlayStyle: lightOverlay,
      );

  static ThemeData get dark => _buildTheme(
        brightness: Brightness.dark,
        extension: KynosThemeExtension.dark,
        overlayStyle: darkOverlay,
      );

  static ThemeData _buildTheme({
    required Brightness brightness,
    required KynosThemeExtension extension,
    required SystemUiOverlayStyle overlayStyle,
  }) {
    final isDark = brightness == Brightness.dark;
    final textTheme = KynosTypography.textTheme(brightness: brightness);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: extension.stand,
        onPrimary: KynosColors.onAccent,
        primaryContainer: extension.stand.withValues(alpha: 0.12),
        onPrimaryContainer: extension.stand,
        secondary: extension.exercise,
        onSecondary: KynosColors.onAccent,
        secondaryContainer: extension.exercise.withValues(alpha: 0.12),
        onSecondaryContainer: extension.exercise,
        tertiary: extension.purple,
        onTertiary: KynosColors.onAccent,
        tertiaryContainer: extension.purple.withValues(alpha: 0.12),
        onTertiaryContainer: extension.purple,
        error: extension.move,
        onError: KynosColors.onAccent,
        errorContainer: extension.move.withValues(alpha: 0.12),
        onErrorContainer: extension.move,
        surface: extension.card,
        onSurface: extension.label,
        surfaceTint: extension.stand.withValues(alpha: 0.05),
        outline: extension.separator,
        outlineVariant: extension.separator.withValues(alpha: 0.6),
        surfaceContainerHighest: extension.background,
        surfaceContainerHigh: extension.background,
        surfaceContainer: extension.card,
        surfaceContainerLow: extension.background,
        surfaceContainerLowest: extension.background,
      ),
      scaffoldBackgroundColor: extension.background,
      textTheme: textTheme,
      extensions: [extension],
      appBarTheme: AppBarTheme(
        backgroundColor: extension.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 56,
        titleTextStyle: textTheme.titleLarge,
        iconTheme: IconThemeData(color: extension.stand),
      ),
      cardTheme: CardThemeData(
        color: extension.card,
        elevation: 0,
        shadowColor: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(tokens.Radius.lg)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: extension.stand,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(54),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(14)),
          ),
          textStyle: KynosTypography.buttonLabel(),
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: extension.stand,
        textColor: extension.label,
        tileColor: extension.card,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: extension.background,
        labelStyle: extension.chipLabelStyle,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tokens.Radius.md),
        ),
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(
          horizontal: tokens.Spacing.sm,
          vertical: tokens.Spacing.xs,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: extension.card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(tokens.Radius.full),
          borderSide: BorderSide(color: extension.separator),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(tokens.Radius.full),
          borderSide: BorderSide(color: extension.separator),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(tokens.Radius.full),
          borderSide: BorderSide(color: extension.stand),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: tokens.Spacing.md,
          vertical: tokens.Spacing.sm,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: extension.separator,
        thickness: 0.5,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return extension.stand;
          return extension.card;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return extension.stand.withValues(alpha: 0.5);
          }
          return extension.separator;
        }),
      ),
      splashFactory: InkRipple.splashFactory,
      pageTransitionsTheme: PageTransitionsTheme(
        builders: {
          TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
