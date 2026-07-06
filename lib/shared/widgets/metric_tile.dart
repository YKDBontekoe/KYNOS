import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:kynos/core/theme/theme.dart';
import 'package:kynos/shared/widgets/kynos_skeleton.dart';

/// Apple Fitness–style metric tile — elevated card, bold number, coloured dot.
class MetricTile extends StatelessWidget {
  const MetricTile({
    super.key,
    required this.label,
    this.value,
    this.unit,
    this.icon,
    this.accentColor,
    this.sublabel,
    this.sublabelColor,
    this.onTap,
    this.compact = false,
    this.flat = false,
  });

  final String label;
  final String? value;
  final String? unit;
  final IconData? icon;
  final Color? accentColor;
  final String? sublabel;
  final Color? sublabelColor;
  final VoidCallback? onTap;
  final bool compact;
  final bool flat;

  @override
  Widget build(BuildContext context) {
    final kynos = context.kynosTheme;
    final theme = Theme.of(context);
    final accent = accentColor ?? kynos.stand;

    final valueLabel = value == null
        ? '$label, loading'
        : unit != null
            ? '$label, $value $unit'
            : '$label, $value';

    return Semantics(
      label: valueLabel,
      button: onTap != null,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
        padding: const EdgeInsets.all(Spacing.md),
        decoration: flat
            ? null
            : BoxDecoration(
                color: kynos.card,
                borderRadius: BorderRadius.circular(Radius.lg),
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
              const Gap(Spacing.xs),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.labelLarge,
                  maxLines: compact ? 1 : 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const Gap(Spacing.sm),
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
                  const Gap(Spacing.xs),
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
          if (sublabel != null) ...[
            const Gap(Spacing.xs),
            Text(
              sublabel!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: sublabelColor ?? kynos.tertiaryLabel,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    ),
      ),
    );
  }
}
