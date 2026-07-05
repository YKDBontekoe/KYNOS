import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:kynos/core/theme/theme.dart';
import 'package:shimmer/shimmer.dart';

/// Shimmer loading line for async card content (per AGENTS.md — no spinners in cards).
class KynosLoadingLine extends StatelessWidget {
  const KynosLoadingLine({
    super.key,
    this.label,
    this.height = 12,
    this.widthFactor = 0.6,
  });

  final String? label;
  final double height;
  final double widthFactor;

  @override
  Widget build(BuildContext context) {
    final kynos = context.kynosTheme;

    final skeleton = Shimmer.fromColors(
      baseColor: kynos.separator,
      highlightColor: kynos.background,
      child: Container(
        height: height,
        width: MediaQuery.sizeOf(context).width * widthFactor,
        decoration: BoxDecoration(
          color: kynos.separator,
          borderRadius: BorderRadius.circular(Radius.sm),
        ),
      ),
    );

    if (label == null) return skeleton;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        skeleton,
        const Gap(Spacing.xs),
        Text(
          label!,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: kynos.tertiaryLabel,
                fontSize: 12,
              ),
        ),
      ],
    );
  }
}
