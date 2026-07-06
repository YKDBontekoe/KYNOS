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
    required this.onboardingTitleStyle,
    required this.onboardingBodyStyle,
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
  final TextStyle onboardingTitleStyle;
  final TextStyle onboardingBodyStyle;

  static final KynosThemeExtension light = KynosThemeExtension(
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
    heroTitleStyle: KynosTypography.heroTitle(),
    heroSubtitleStyle: KynosTypography.heroSubtitle(),
    chipLabelStyle: KynosTypography.chipLabel(Brightness.light),
    onboardingTitleStyle: KynosTypography.onboardingTitle(Brightness.light),
    onboardingBodyStyle: KynosTypography.onboardingBody(Brightness.light),
  );

  static final KynosThemeExtension dark = KynosThemeExtension(
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
    heroTitleStyle: KynosTypography.heroTitle(),
    heroSubtitleStyle: KynosTypography.heroSubtitle(),
    chipLabelStyle: KynosTypography.chipLabel(Brightness.dark),
    onboardingTitleStyle: KynosTypography.onboardingTitle(Brightness.dark),
    onboardingBodyStyle: KynosTypography.onboardingBody(Brightness.dark),
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
    TextStyle? onboardingTitleStyle,
    TextStyle? onboardingBodyStyle,
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
        onboardingTitleStyle: onboardingTitleStyle ?? this.onboardingTitleStyle,
        onboardingBodyStyle: onboardingBodyStyle ?? this.onboardingBodyStyle,
      );

  @override
  KynosThemeExtension lerp(
    covariant ThemeExtension<KynosThemeExtension>? other,
    double t,
  ) {
    if (other is! KynosThemeExtension) return this;
    return KynosThemeExtension(
      move: Color.lerp(move, other.move, t)!,
      exercise: Color.lerp(exercise, other.exercise, t)!,
      stand: Color.lerp(stand, other.stand, t)!,
      energy: Color.lerp(energy, other.energy, t)!,
      purple: Color.lerp(purple, other.purple, t)!,
      willpower: Color.lerp(willpower, other.willpower, t)!,
      background: Color.lerp(background, other.background, t)!,
      card: Color.lerp(card, other.card, t)!,
      label: Color.lerp(label, other.label, t)!,
      secondaryLabel: Color.lerp(secondaryLabel, other.secondaryLabel, t)!,
      tertiaryLabel: Color.lerp(tertiaryLabel, other.tertiaryLabel, t)!,
      separator: Color.lerp(separator, other.separator, t)!,
      navUnselected: Color.lerp(navUnselected, other.navUnselected, t)!,
      glassFill: Color.lerp(glassFill, other.glassFill, t)!,
      glassBorder: Color.lerp(glassBorder, other.glassBorder, t)!,
      heroOrbOverlay: Color.lerp(heroOrbOverlay, other.heroOrbOverlay, t)!,
      cardShadow: t < 0.5 ? cardShadow : other.cardShadow,
      metricTileShadow: t < 0.5 ? metricTileShadow : other.metricTileShadow,
      navBarShadow: t < 0.5 ? navBarShadow : other.navBarShadow,
      sectionLabelStyle:
          TextStyle.lerp(sectionLabelStyle, other.sectionLabelStyle, t)!,
      metricValueStyle:
          TextStyle.lerp(metricValueStyle, other.metricValueStyle, t)!,
      heroTitleStyle: TextStyle.lerp(heroTitleStyle, other.heroTitleStyle, t)!,
      heroSubtitleStyle:
          TextStyle.lerp(heroSubtitleStyle, other.heroSubtitleStyle, t)!,
      chipLabelStyle: TextStyle.lerp(chipLabelStyle, other.chipLabelStyle, t)!,
      onboardingTitleStyle:
          TextStyle.lerp(onboardingTitleStyle, other.onboardingTitleStyle, t)!,
      onboardingBodyStyle:
          TextStyle.lerp(onboardingBodyStyle, other.onboardingBodyStyle, t)!,
    );
  }
}

extension KynosThemeContext on BuildContext {
  KynosThemeExtension get kynosTheme =>
      Theme.of(this).extension<KynosThemeExtension>() ??
      KynosThemeExtension.light;
}
