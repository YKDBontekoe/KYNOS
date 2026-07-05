import 'package:flutter/material.dart';
import 'package:kynos/core/theme/spacing.dart' as tokens;

/// Layout constants for consistent page structure.
abstract final class LayoutTokens {
  /// Bottom scroll padding to clear the floating shell nav bar.
  static const double shellBottomPadding =
      tokens.Spacing.xxxl * 2 + tokens.Spacing.xl + tokens.Spacing.lg;

  static const double heroBannerHeight =
      tokens.Spacing.xxxl * 2 + tokens.Spacing.sm - tokens.Spacing.xs;

  static const double heroBannerHeightLarge =
      tokens.Spacing.xxxl * 2 + tokens.Spacing.xl;

  static const EdgeInsets heroBannerPadding = EdgeInsets.symmetric(
    horizontal: tokens.Spacing.lg -
        tokens.Spacing.xs +
        tokens.Spacing.xs ~/ 2,
    vertical: tokens.Spacing.md + tokens.Spacing.xs,
  );

  static const double appBarToolbarHeight = tokens.Spacing.xl + tokens.Spacing.lg;
  static const double titleSpacing = tokens.Spacing.lg - tokens.Spacing.xs;

  static const EdgeInsets shellNavPadding = EdgeInsets.only(
    bottom: tokens.Spacing.md + tokens.Spacing.xs,
    left: tokens.Spacing.md,
    right: tokens.Spacing.md,
  );

  static const EdgeInsets settingsSectionPadding =
      EdgeInsets.fromLTRB(
        tokens.Spacing.md,
        tokens.Spacing.lg,
        tokens.Spacing.md,
        tokens.Spacing.sm,
      );
}
