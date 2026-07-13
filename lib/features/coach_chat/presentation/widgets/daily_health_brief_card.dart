import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:kynos/core/theme/theme.dart';
import 'package:kynos/domain/entities/health/health_coach_models.dart';
import 'package:kynos/shared/widgets/kynos_card.dart';
import 'package:kynos/shared/widgets/kynos_chip.dart';

class DailyHealthBriefCard extends StatelessWidget {
  const DailyHealthBriefCard({super.key, required this.brief});

  final DailyHealthBrief brief;

  @override
  Widget build(BuildContext context) {
    return KynosCard(
      padding: const EdgeInsets.all(Spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Your health brief',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              KynosChip(
                label: brief.baselineQuality == BaselineQuality.stable
                    ? 'Personal baseline'
                    : 'Learning',
              ),
            ],
          ),
          const Gap(Spacing.sm),
          Text(
            brief.bodyStateSummary,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          if (brief.findings.isNotEmpty) ...[
            const Gap(Spacing.md),
            for (final finding in brief.findings) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    finding.basis == FindingBasis.selfReported
                        ? Icons.person_outline_rounded
                        : Icons.monitor_heart_outlined,
                    size: 18,
                    color: context.kynosTheme.purple,
                  ),
                  const Gap(Spacing.sm),
                  Expanded(child: Text(finding.observation)),
                ],
              ),
              const Gap(Spacing.sm),
            ],
          ],
          const Gap(Spacing.sm),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(Spacing.md),
            decoration: BoxDecoration(
              color: context.kynosTheme.purple.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(Radius.md),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ONE USEFUL ACTION',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                const Gap(Spacing.xs),
                Text(brief.primaryAction),
              ],
            ),
          ),
          const Gap(Spacing.sm),
          Text(
            'Alternative: ${brief.alternativeAction}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: context.kynosTheme.secondaryLabel,
            ),
          ),
        ],
      ),
    );
  }
}
