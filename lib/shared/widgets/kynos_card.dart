import 'package:flutter/material.dart';
import 'package:kynos/core/theme/kynos_theme_extension.dart';
import 'package:kynos/core/theme/spacing.dart' as tokens;

/// Base card following KYNOS Apple Fitness design language.
class KynosCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? color;
  final bool elevated;

  const KynosCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(tokens.Spacing.md),
    this.onTap,
    this.color,
    this.elevated = false,
  });

  @override
  Widget build(BuildContext context) {
    final kynos = context.kynosTheme;
    final cardColor = color ?? kynos.card;

    if (elevated) {
      return Material(
        color: cardColor,
        elevation: 0,
        shadowColor: Colors.transparent,
        borderRadius: BorderRadius.circular(tokens.Radius.lg),
        child: InkWell(
          borderRadius: BorderRadius.circular(tokens.Radius.lg),
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(tokens.Radius.lg),
              boxShadow: kynos.cardShadow,
            ),
            padding: padding,
            child: child,
          ),
        ),
      );
    }

    return Card(
      color: cardColor,
      child: InkWell(
        borderRadius: BorderRadius.circular(tokens.Radius.lg),
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
