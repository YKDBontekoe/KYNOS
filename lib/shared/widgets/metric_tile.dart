import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:kynos/core/theme/kynos_theme_extension.dart';
import 'package:kynos/core/theme/spacing.dart' as tokens;
import 'package:kynos/shared/widgets/kynos_skeleton.dart';

/// Apple Fitness–style metric tile — elevated card, bold number, coloured dot.
class MetricTile extends StatelessWidget {
  final String label;
  final String? value;
  final String? unit;
  final IconData? icon;
  final Color? accentColor;

  const MetricTile({
    super.key,
    required this.label,
    this.value,
    this.unit,
    this.icon,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final kynos = context.kynosTheme;
    final theme = Theme.of(context);
    final accent = accentColor ?? kynos.stand;

    return Container(
      padding: const EdgeInsets.all(tokens.Spacing.md),
      decoration: BoxDecoration(
        color: kynos.card,
        borderRadius: BorderRadius.circular(tokens.Radius.lg),
        boxShadow: kynos.metricTileShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: accent,
                  shape: BoxShape.circle,
                ),
              ),
              const Gap(tokens.Spacing.xs),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.labelLarge,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const Gap(tokens.Spacing.sm),
          if (value == null)
            const KynosSkeleton(height: 32, width: 70)
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    value!,
                    key: ValueKey(value),
                    style: kynos.metricValueStyle,
                  ),
                ),
                if (unit != null) ...[
                  const Gap(tokens.Spacing.xs),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(
                      unit!,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ],
            ),
        ],
      ),
    );
  }
}
