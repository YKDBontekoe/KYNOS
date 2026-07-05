import 'package:flutter/material.dart';
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

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == activeIndex;
        return Container(
          width: active ? 16 : 6,
          height: 6,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color: active ? kynos.stand : kynos.separator,
            borderRadius: BorderRadius.circular(Radius.full),
          ),
        );
      }),
    );
  }
}
