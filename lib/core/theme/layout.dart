import 'package:flutter/material.dart';
import 'package:kynos/core/theme/spacing.dart' as tokens;

/// Layout constants for consistent page structure.
abstract final class LayoutTokens {
  /// Bottom scroll padding to clear the floating shell nav bar.
  static const double shellBottomPadding = 168;

  static const double heroBannerHeight = 130;
  static const double heroBannerHeightLarge = 160;

  static const EdgeInsets heroBannerPadding =
      EdgeInsets.symmetric(horizontal: 22, vertical: 20);

  static const double appBarToolbarHeight = 56;
  static const double titleSpacing = 20;

  static const EdgeInsets shellNavPadding =
      EdgeInsets.only(bottom: 20, left: 16, right: 16);

  static const EdgeInsets settingsSectionPadding =
      EdgeInsets.fromLTRB(
        tokens.Spacing.md,
        tokens.Spacing.lg,
        tokens.Spacing.md,
        tokens.Spacing.sm,
      );
}
