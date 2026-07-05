import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:kynos/core/theme/theme.dart';

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
    this.actionLabel,
    this.onActionTap,
  });

  final Color accentColor;
  final String? subtitle;
  final String? title;
  final String? caption;
  final Widget? child;
  final double height;
  final Alignment orbAlignment;
  final String? actionLabel;
  final VoidCallback? onActionTap;

  @override
  Widget build(BuildContext context) {
    final kynos = context.kynosTheme;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: accentColor,
        borderRadius: BorderRadius.circular(Radius.hero),
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          Positioned(
            top: orbAlignment == Alignment.topLeft ||
                    orbAlignment == Alignment.topRight
                ? -40
                : null,
            left: orbAlignment == Alignment.topLeft ||
                    orbAlignment == Alignment.bottomLeft
                ? -40
                : null,
            right: orbAlignment == Alignment.topRight ||
                    orbAlignment == Alignment.bottomRight
                ? -40
                : null,
            bottom: orbAlignment == Alignment.bottomLeft ||
                    orbAlignment == Alignment.bottomRight
                ? -40
                : null,
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
              orbAlignment == Alignment.topRight)
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
                      const Gap(Spacing.xs),
                    if (title != null)
                      Text(title!, style: kynos.heroTitleStyle),
                    if (caption != null) ...[
                      const Gap(Spacing.xs),
                      Text(
                        caption!,
                        style: kynos.heroSubtitleStyle.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: KynosColors.onAccent.withValues(alpha: 0.60),
                        ),
                      ),
                    ],
                  ],
                ),
          ),
          if (actionLabel != null && onActionTap != null)
            Positioned(
              right: Spacing.md,
              bottom: Spacing.md,
              child: TextButton(
                onPressed: onActionTap,
                style: TextButton.styleFrom(
                  foregroundColor: KynosColors.onAccent,
                  backgroundColor: KynosColors.onAccent.withValues(alpha: 0.15),
                  padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.md,
                    vertical: Spacing.xs,
                  ),
                ),
                child: Text(actionLabel!),
              ),
            ),
        ],
      ),
    );
  }
}
