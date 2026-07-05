import 'package:flutter/material.dart';
import 'package:kynos/core/theme/colors.dart';
import 'package:kynos/core/theme/elevation.dart';
import 'package:kynos/core/theme/typography.dart';

/// Semantic theme extension for KYNOS-specific tokens.
@immutable
class KynosThemeExtension extends ThemeExtension<KynosThemeExtension> {
  const KynosThemeExtension({
    required this.move,
    required this.exercise,
    required this.stand,
    required this.energy,
    required this.purple,
    required this.willpower,
    required this.background,
    required this.card,
    required this.label,
    required this.secondaryLabel,
    required this.tertiaryLabel,
    required this.separator,
    required this.navUnselected,
    required this.glassFill,
    required this.glassBorder,
    required this.heroOrbOverlay,
    required this.cardShadow,
    required this.metricTileShadow,
    required this.navBarShadow,
    required this.sectionLabelStyle,
    required this.metricValueStyle,
    required this.heroTitleStyle,
    required this.heroSubtitleStyle,
    required this.chipLabelStyle,
  });

  final Color move;
  final Color exercise;
  final Color stand;
  final Color energy;
  final Color purple;
  final Color willpower;
  final Color background;
  final Color card;
  final Color label;
  final Color secondaryLabel;
  final Color tertiaryLabel;
  final Color separator;
  final Color navUnselected;
  final Color glassFill;
  final Color glassBorder;
  final Color heroOrbOverlay;
  final List<BoxShadow> cardShadow;
  final List<BoxShadow> metricTileShadow;
  final List<BoxShadow> navBarShadow;
  final TextStyle sectionLabelStyle;
  final TextStyle metricValueStyle;
  final TextStyle heroTitleStyle;
  final TextStyle heroSubtitleStyle;
  final TextStyle chipLabelStyle;

  static KynosThemeExtension light = KynosThemeExtension(
    move: KynosColors.move,
    exercise: KynosColors.exercise,
    stand: KynosColors.stand,
    energy: KynosColors.energy,
    purple: KynosColors.purple,
    willpower: KynosColors.willpower,
    background: KynosColors.background,
    card: KynosColors.card,
    label: KynosColors.label,
    secondaryLabel: KynosColors.secondaryLabel,
    tertiaryLabel: KynosColors.tertiaryLabel,
    separator: KynosColors.separator,
    navUnselected: KynosColors.navUnselected,
    glassFill: KynosColors.glassFillLight(),
    glassBorder: KynosColors.glassBorderLight(),
    heroOrbOverlay: KynosColors.heroOrbOverlay(),
    cardShadow: KynosElevation.cardSubtle(Brightness.light),
    metricTileShadow: KynosElevation.metricTile(Brightness.light),
    navBarShadow: KynosElevation.navBar(Brightness.light),
    sectionLabelStyle: KynosTypography.sectionLabel(Brightness.light),
    metricValueStyle: KynosTypography.metricValue(Brightness.light),
    heroTitleStyle: KynosTypography.heroTitle(Brightness.light),
    heroSubtitleStyle: KynosTypography.heroSubtitle(Brightness.light),
    chipLabelStyle: KynosTypography.chipLabel(Brightness.light),
  );

  static KynosThemeExtension dark = KynosThemeExtension(
    move: KynosColors.move,
    exercise: KynosColors.exercise,
    stand: KynosColors.stand,
    energy: KynosColors.energy,
    purple: KynosColors.purple,
    willpower: KynosColors.willpower,
    background: KynosColors.backgroundDark,
    card: KynosColors.cardDark,
    label: KynosColors.labelDark,
    secondaryLabel: KynosColors.secondaryLabelDark,
    tertiaryLabel: KynosColors.tertiaryLabelDark,
    separator: KynosColors.separatorDark,
    navUnselected: KynosColors.navUnselected,
    glassFill: KynosColors.glassFillDark(),
    glassBorder: KynosColors.glassBorderDark(),
    heroOrbOverlay: KynosColors.heroOrbOverlay(alpha: 0.08),
    cardShadow: KynosElevation.cardSubtle(Brightness.dark),
    metricTileShadow: KynosElevation.metricTile(Brightness.dark),
    navBarShadow: KynosElevation.navBar(Brightness.dark),
    sectionLabelStyle: KynosTypography.sectionLabel(Brightness.dark),
    metricValueStyle: KynosTypography.metricValue(Brightness.dark),
    heroTitleStyle: KynosTypography.heroTitle(Brightness.dark),
    heroSubtitleStyle: KynosTypography.heroSubtitle(Brightness.dark),
    chipLabelStyle: KynosTypography.chipLabel(Brightness.dark),
  );

  Color accentForKey(String key) => KynosColors.accentForKey(key);

  @override
  KynosThemeExtension copyWith({
    Color? move,
    Color? exercise,
    Color? stand,
    Color? energy,
    Color? purple,
    Color? willpower,
    Color? background,
    Color? card,
    Color? label,
    Color? secondaryLabel,
    Color? tertiaryLabel,
    Color? separator,
    Color? navUnselected,
    Color? glassFill,
    Color? glassBorder,
    Color? heroOrbOverlay,
    List<BoxShadow>? cardShadow,
    List<BoxShadow>? metricTileShadow,
    List<BoxShadow>? navBarShadow,
    TextStyle? sectionLabelStyle,
    TextStyle? metricValueStyle,
    TextStyle? heroTitleStyle,
    TextStyle? heroSubtitleStyle,
    TextStyle? chipLabelStyle,
  }) =>
      KynosThemeExtension(
        move: move ?? this.move,
        exercise: exercise ?? this.exercise,
        stand: stand ?? this.stand,
        energy: energy ?? this.energy,
        purple: purple ?? this.purple,
        willpower: willpower ?? this.willpower,
        background: background ?? this.background,
        card: card ?? this.card,
        label: label ?? this.label,
        secondaryLabel: secondaryLabel ?? this.secondaryLabel,
        tertiaryLabel: tertiaryLabel ?? this.tertiaryLabel,
        separator: separator ?? this.separator,
        navUnselected: navUnselected ?? this.navUnselected,
        glassFill: glassFill ?? this.glassFill,
        glassBorder: glassBorder ?? this.glassBorder,
        heroOrbOverlay: heroOrbOverlay ?? this.heroOrbOverlay,
        cardShadow: cardShadow ?? this.cardShadow,
        metricTileShadow: metricTileShadow ?? this.metricTileShadow,
        navBarShadow: navBarShadow ?? this.navBarShadow,
        sectionLabelStyle: sectionLabelStyle ?? this.sectionLabelStyle,
        metricValueStyle: metricValueStyle ?? this.metricValueStyle,
        heroTitleStyle: heroTitleStyle ?? this.heroTitleStyle,
        heroSubtitleStyle: heroSubtitleStyle ?? this.heroSubtitleStyle,
        chipLabelStyle: chipLabelStyle ?? this.chipLabelStyle,
      );

  @override
  KynosThemeExtension lerp(
    covariant ThemeExtension<KynosThemeExtension>? other,
    double t,
  ) {
    if (other is! KynosThemeExtension) return this;
    return t < 0.5 ? this : other;
  }
}

extension KynosThemeContext on BuildContext {
  KynosThemeExtension get kynosTheme =>
      Theme.of(this).extension<KynosThemeExtension>() ??
      KynosThemeExtension.light;
}
