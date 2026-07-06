import 'package:flutter/material.dart';
import 'package:kynos/core/theme/spacing.dart' as tokens;
import 'package:kynos/core/theme/theme.dart';

/// Page indicator dots for carousels.
class KynosPageDots extends StatelessWidget {
  const KynosPageDots({
    super.key,
    required this.count,
    required this.activeIndex,
  });

  final int count;
  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    final kynos = context.kynosTheme;

    return Semantics(
      label: 'Page ${activeIndex + 1} of $count',
      child: ExcludeSemantics(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(count, (i) {
            final active = i == activeIndex;
            return Container(
              width: active ? tokens.Spacing.lg : tokens.Spacing.xs + 2,
              height: tokens.Spacing.xs + 2,
              margin: const EdgeInsets.symmetric(
                horizontal: tokens.Spacing.xs - 1,
              ),
              decoration: BoxDecoration(
                color: active ? kynos.stand : kynos.separator,
                borderRadius: BorderRadius.circular(Radius.full),
              ),
            );
          }),
        ),
      ),
    );
  }
}
