import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:kynos/core/theme/kynos_theme_extension.dart';
import 'package:kynos/core/theme/layout.dart';
import 'package:kynos/core/theme/spacing.dart' as tokens;

/// Coloured hero banner with decorative orb — used on tab landing screens.
class KynosHeroBanner extends StatelessWidget {
  const KynosHeroBanner({
    super.key,
    required this.accentColor,
    this.subtitle,
    this.title,
    this.caption,
    this.child,
    this.height = LayoutTokens.heroBannerHeight,
    this.orbAlignment = Alignment.topLeft,
  });

  final Color accentColor;
  final String? subtitle;
  final String? title;
  final String? caption;
  final Widget? child;
  final double height;
  final Alignment orbAlignment;

  @override
  Widget build(BuildContext context) {
    final kynos = context.kynosTheme;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: accentColor,
        borderRadius: BorderRadius.circular(tokens.Radius.hero),
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          Positioned(
            top: orbAlignment == Alignment.topLeft ? -40 : null,
            left: orbAlignment == Alignment.topLeft ? -40 : null,
            right: orbAlignment == Alignment.topRight ? -40 : null,
            bottom: orbAlignment == Alignment.bottomLeft ? -30 : null,
            child: Container(
              width: height > LayoutTokens.heroBannerHeight ? 200 : 180,
              height: height > LayoutTokens.heroBannerHeight ? 200 : 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: kynos.heroOrbOverlay,
              ),
            ),
          ),
          if (height > LayoutTokens.heroBannerHeight &&
              orbAlignment != Alignment.bottomLeft)
            Positioned(
              bottom: -30,
              left: -20,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: kynos.heroOrbOverlay.withValues(alpha: 0.05),
                ),
              ),
            ),
          Padding(
            padding: LayoutTokens.heroBannerPadding,
            child: child ??
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (subtitle != null)
                      Text(subtitle!, style: kynos.heroSubtitleStyle),
                    if (subtitle != null && title != null)
                      const Gap(tokens.Spacing.xs),
                    if (title != null)
                      Text(title!, style: kynos.heroTitleStyle),
                    if (caption != null) ...[
                      const Gap(tokens.Spacing.xs),
                      Text(
                        caption!,
                        style: kynos.heroSubtitleStyle.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withValues(alpha: 0.60),
                        ),
                      ),
                    ],
                  ],
                ),
          ),
        ],
      ),
    );
  }
}
