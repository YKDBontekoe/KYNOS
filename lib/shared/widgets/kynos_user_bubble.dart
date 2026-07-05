import 'package:flutter/material.dart';
import 'package:kynos/core/theme/kynos_theme_extension.dart';
import 'package:kynos/core/theme/spacing.dart' as tokens;

/// User chat bubble — solid accent fill.
class KynosUserBubble extends StatelessWidget {
  const KynosUserBubble({
    super.key,
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    final kynos = context.kynosTheme;

    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.78,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: tokens.Spacing.md,
          vertical: tokens.Spacing.sm,
        ),
        decoration: BoxDecoration(
          color: kynos.stand,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(tokens.Radius.lg),
            topRight: Radius.circular(tokens.Radius.lg),
            bottomLeft: Radius.circular(tokens.Radius.lg),
            bottomRight: Radius.circular(4),
          ),
        ),
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white,
              ),
        ),
      ),
    );
  }
}
