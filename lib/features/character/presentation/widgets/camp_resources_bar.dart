import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:kynos/core/theme/spacing.dart' as tokens;
import 'package:kynos/core/theme/theme.dart';
import 'package:kynos/domain/entities/gamification/camp_resources.dart';
import 'package:kynos/shared/widgets/kynos_card.dart';
import 'package:kynos/shared/widgets/kynos_loading_line.dart';

class CampResourcesBar extends StatelessWidget {
  const CampResourcesBar({
    super.key,
    required this.resources,
    this.isLoading = false,
  });

  final CampResources resources;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final kynos = context.kynosTheme;

    if (isLoading) {
      return const KynosCard(
        child: KynosLoadingLine(label: 'Loading camp resources...'),
      );
    }

    return KynosCard(
      padding: const EdgeInsets.symmetric(
        horizontal: tokens.Spacing.md,
        vertical: tokens.Spacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: _ResourceChip(
              label: 'Momentum',
              value: resources.availableMomentum,
              total: resources.totalMomentum,
              color: kynos.move,
            ),
          ),
          const Gap(tokens.Spacing.xs),
          Expanded(
            child: _ResourceChip(
              label: 'Fuel',
              value: resources.availableFuel,
              total: resources.totalFuel,
              color: kynos.energy,
            ),
          ),
          const Gap(tokens.Spacing.xs),
          Expanded(
            child: _ResourceChip(
              label: 'Focus',
              value: resources.availableFocus,
              total: resources.totalFocus,
              color: kynos.stand,
            ),
          ),
          const Gap(tokens.Spacing.xs),
          Expanded(
            child: _ResourceChip(
              label: 'Spirit',
              value: resources.availableSpirit,
              total: resources.totalSpirit,
              color: kynos.purple,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResourceChip extends StatelessWidget {
  const _ResourceChip({
    required this.label,
    required this.value,
    required this.total,
    required this.color,
  });

  final String label;
  final int value;
  final int total;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final kynos = context.kynosTheme;
    return Column(
      children: [
        Text(
          label.toUpperCase(),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: kynos.tertiaryLabel,
                fontSize: 9,
              ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const Gap(tokens.Spacing.xs),
        Text(
          '$value',
          style: kynos.metricValueStyle.copyWith(
            color: color,
            fontSize: 16,
          ),
        ),
        Text(
          '/$total',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: kynos.tertiaryLabel,
                fontSize: 10,
              ),
        ),
      ],
    );
  }
}
