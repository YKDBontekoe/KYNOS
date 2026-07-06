import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kynos/core/theme/liquid_glass_tokens.dart';
import 'package:kynos/core/theme/spacing.dart' as tokens;
import 'package:kynos/core/theme/typography.dart';
import 'package:kynos/shared/widgets/liquid_glass_surface.dart';

/// Pill-shaped Liquid Glass text button — for hero actions and floating CTAs.
class LiquidGlassButton extends StatelessWidget {
  const LiquidGlassButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.onAccent = false,
    this.icon,
    this.iconHeroTag,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool onAccent;
  final IconData? icon;
  final String? iconHeroTag;

  @override
  Widget build(BuildContext context) {
    final foreground = onAccent
        ? Colors.white
        : Theme.of(context).colorScheme.primary;

    return Semantics(
      button: true,
      label: label,
      enabled: onPressed != null,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed == null
              ? null
              : () {
                  HapticFeedback.lightImpact();
                  onPressed!();
                },
          borderRadius: BorderRadius.circular(tokens.Radius.full),
          child: LiquidGlassSurface(
            borderRadius: tokens.Radius.full,
            blurSigma: LiquidGlassTokens.buttonBlurSigma,
            onAccent: onAccent,
            padding: const EdgeInsets.symmetric(
              horizontal: tokens.Spacing.md,
              vertical: tokens.Spacing.sm,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  iconHeroTag != null
                      ? Hero(
                          tag: iconHeroTag!,
                          child: Icon(icon, size: 18, color: foreground),
                        )
                      : Icon(icon, size: 18, color: foreground),
                  const SizedBox(width: tokens.Spacing.xs),
                ],
                Text(
                  label,
                  style: KynosTypography.buttonLabel().copyWith(
                    color: foreground,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Circular Liquid Glass icon button — for toolbar and input-bar actions.
class LiquidGlassIconButton extends StatelessWidget {
  const LiquidGlassIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.onAccent = false,
    this.size = 40,
    this.iconSize = 22,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final bool onAccent;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final foreground = onAccent
        ? Colors.white
        : Theme.of(context).colorScheme.primary;

    final button = Semantics(
      button: true,
      label: tooltip,
      enabled: onPressed != null,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed == null
              ? null
              : () {
                  HapticFeedback.lightImpact();
                  onPressed!();
                },
          customBorder: const CircleBorder(),
          child: LiquidGlassSurface(
            borderRadius: size / 2,
            blurSigma: LiquidGlassTokens.buttonBlurSigma,
            onAccent: onAccent,
            padding: EdgeInsets.zero,
            child: SizedBox(
              width: size,
              height: size,
              child: Icon(icon, size: iconSize, color: foreground),
            ),
          ),
        ),
      ),
    );

    final tip = tooltip;
    if (tip != null) {
      return Tooltip(message: tip, child: button);
    }
    return button;
  }
}
