import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:kynos/core/theme/spacing.dart' as tokens;
import 'package:kynos/core/theme/theme.dart';
import 'package:kynos/domain/entities/gamification/activity_resources.dart';

class ActivityResourcesBar extends StatelessWidget {
  const ActivityResourcesBar({super.key, required this.resources});

  final ActivityResources resources;

  @override
  Widget build(BuildContext context) {
    final kynos = context.kynosTheme;
    final theme = Theme.of(context).textTheme;

    return Row(
      children: [
        Expanded(
          child: _ResourceTile(
            label: 'MOVES',
            value: '${resources.availableMovePoints}',
            sub: '/ ${resources.totalMovePoints}',
            color: kynos.move,
            valueStyle: kynos.metricValueStyle.copyWith(fontSize: 20),
            labelStyle: theme.labelSmall,
          ),
        ),
        const Gap(tokens.Spacing.sm),
        Expanded(
          child: _ResourceTile(
            label: 'STAMINA',
            value: '${resources.availableStamina}',
            sub: '/ ${resources.totalStamina}',
            color: kynos.energy,
            valueStyle: kynos.metricValueStyle.copyWith(fontSize: 20),
            labelStyle: theme.labelSmall,
          ),
        ),
      ],
    );
  }
}

class _ResourceTile extends StatelessWidget {
  const _ResourceTile({
    required this.label,
    required this.value,
    required this.sub,
    required this.color,
    required this.valueStyle,
    required this.labelStyle,
  });

  final String label;
  final String value;
  final String sub;
  final Color color;
  final TextStyle valueStyle;
  final TextStyle? labelStyle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(tokens.Spacing.sm),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(Radius.md),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: labelStyle?.copyWith(
              color: AppTheme.tertiaryLabel,
              letterSpacing: 0.6,
            ),
          ),
          const Gap(tokens.Spacing.xs),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value, style: valueStyle.copyWith(color: color)),
              Text(
                sub,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.secondaryLabel,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
