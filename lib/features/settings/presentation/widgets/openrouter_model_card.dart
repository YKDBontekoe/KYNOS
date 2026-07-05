import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:kynos/core/theme/kynos_theme_extension.dart';
import 'package:kynos/core/theme/spacing.dart' as tokens;
import 'package:kynos/domain/entities/openrouter_model.dart';
import 'package:kynos/shared/widgets/kynos_card.dart';
import 'package:kynos/shared/widgets/kynos_chip.dart';

class OpenRouterModelCard extends StatelessWidget {
  const OpenRouterModelCard({
    super.key,
    required this.model,
    required this.onTap,
    this.isSelected = false,
  });

  final OpenRouterModel model;
  final VoidCallback onTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final kynos = context.kynosTheme;
    final pricing = formatOpenRouterPricing(model);
    final isFree = isFreeOpenRouterModel(model);

    return Padding(
      padding: const EdgeInsets.only(bottom: tokens.Spacing.sm),
      child: KynosCard(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    model.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                if (isSelected)
                  Icon(Icons.check_circle, color: kynos.stand, size: 20),
              ],
            ),
            const Gap(tokens.Spacing.xs),
            Text(
              model.id,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: kynos.secondaryLabel,
                  ),
            ),
            const Gap(tokens.Spacing.sm),
            Wrap(
              spacing: tokens.Spacing.xs,
              runSpacing: tokens.Spacing.xs,
              children: [
                if (isFree) const KynosChip.accent(label: 'Free', color: Colors.green),
                KynosChip.metric(label: 'Price', value: pricing),
                KynosChip.metric(
                  label: 'Context',
                  value: _formatContext(model.contextLength),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatContext(int tokens) {
    if (tokens >= 1000000) {
      return '${(tokens / 1000000).toStringAsFixed(1)}M';
    }
    if (tokens >= 1000) return '${(tokens / 1000).round()}K';
    return '$tokens';
  }
}
