import 'package:flutter/material.dart';
import 'package:kynos/core/theme/theme.dart';
import 'package:shimmer/shimmer.dart';

/// Generic shimmer skeleton block for full-page loading states.
class KynosSkeleton extends StatelessWidget {
  const KynosSkeleton({
    super.key,
    this.height = 16,
    this.width,
    this.borderRadius = Radius.sm,
  });

  const KynosSkeleton.tile({
    super.key,
    this.height = 80,
    this.width,
  }) : borderRadius = Radius.lg;

  final double height;
  final double? width;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final kynos = context.kynosTheme;

    return Shimmer.fromColors(
      baseColor: kynos.separator,
      highlightColor: kynos.background,
      child: Container(
        height: height,
        width: width ?? double.infinity,
        decoration: BoxDecoration(
          color: kynos.separator,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}
