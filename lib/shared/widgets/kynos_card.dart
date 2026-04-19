import 'package:flutter/material.dart';
import 'package:kynos/core/theme/spacing.dart' as tokens;

/// Base card following KYNOS dark-glass design language.
class KynosCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? color;

  const KynosCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(tokens.Spacing.md),
    this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      child: InkWell(
        borderRadius: BorderRadius.circular(tokens.Radius.lg),
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
