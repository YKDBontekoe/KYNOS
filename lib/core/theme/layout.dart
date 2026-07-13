import 'package:flutter/material.dart';
import 'package:kynos/core/theme/spacing.dart' as tokens;

/// Layout constants for consistent page structure.
abstract final class LayoutTokens {
  /// Diameter of the draggable shell floating navigation button.
  static const double shellFloatingNavSize = 52;

  /// @deprecated Use [shellFloatingNavSize]. Kept for legacy nav references.
  static const double shellRailWidth = shellFloatingNavSize;

  /// @deprecated Use [shellFloatingNavSize]. Kept for legacy bottom-nav references.
  static const double shellNavBarHeight = shellFloatingNavSize;

  /// Total bottom inset — floating nav no longer reserves layout chrome.
  static double shellNavExtent(BuildContext context) => 0;

  /// Bottom scroll padding for tab content (safe-area aware).
  static double shellBottomPadding(BuildContext context) =>
      tokens.Spacing.xxxl +
      MediaQuery.viewPaddingOf(context).bottom;

  /// @deprecated Prefer [shellBottomPadding] with context for safe-area.
  static const double shellBottomPaddingLegacy =
      tokens.Spacing.xxxl + tokens.Spacing.lg;

  static const double heroBannerHeight =
      tokens.Spacing.xxxl * 2 + tokens.Spacing.sm - tokens.Spacing.xs;

  static const double heroBannerHeightLarge =
      tokens.Spacing.xxxl * 2 + tokens.Spacing.xl;

  static const EdgeInsets heroBannerPadding = EdgeInsets.symmetric(
    horizontal: tokens.Spacing.lg - tokens.Spacing.xs + tokens.Spacing.xs ~/ 2,
    vertical: tokens.Spacing.md + tokens.Spacing.xs,
  );

  static const double appBarToolbarHeight =
      tokens.Spacing.xl + tokens.Spacing.lg;
  static const double titleSpacing = tokens.Spacing.lg - tokens.Spacing.xs;

  static const EdgeInsets shellNavPadding = EdgeInsets.only(
    bottom: tokens.Spacing.md + tokens.Spacing.xs,
    left: tokens.Spacing.md,
    right: tokens.Spacing.md,
  );

  static const EdgeInsets shellRailPadding = EdgeInsets.only(
    left: tokens.Spacing.xs,
  );

  static const EdgeInsets settingsSectionPadding = EdgeInsets.fromLTRB(
    tokens.Spacing.md,
    tokens.Spacing.lg,
    tokens.Spacing.md,
    tokens.Spacing.sm,
  );

  /// Max content width for web and wide viewports.
  static const double maxContentWidth = 560;

  /// Bottom padding to clear the coach chat input bar.
  static const double chatInputClearance =
      tokens.Spacing.xxxl * 2 + tokens.Spacing.md;

  /// Extra bottom offset for the shell FAB on the coach tab (above input bar).
  static const double coachChatFabBottomInset =
      tokens.Spacing.xxxl + tokens.Spacing.md;

  /// Left inset for coach chat input so text does not sit under the shell FAB.
  static const double coachFabLeftClearance =
      shellFloatingNavSize + tokens.Spacing.md;

  /// Height for horizontal run-card carousels on the dashboard.
  static const double runCarouselHeight =
      tokens.Spacing.xxxl * 2 + tokens.Spacing.xl + tokens.Spacing.md;

  /// Width for horizontal run-card carousel tiles.
  static const double runCarouselTileWidth =
      tokens.Spacing.xxxl * 5 + tokens.Spacing.lg;

  /// Height for dashboard trend carousel charts.
  static const double trendCarouselHeight =
      tokens.Spacing.xxxl * 4 + tokens.Spacing.md;
}
