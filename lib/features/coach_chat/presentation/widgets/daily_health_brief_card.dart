import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:kynos/core/theme/theme.dart';
import 'package:kynos/domain/entities/health/health_coach_models.dart';
import 'package:kynos/shared/widgets/kynos_card.dart';

class DailyHealthBriefCard extends StatelessWidget {
  const DailyHealthBriefCard({
    super.key,
    required this.brief,
    required this.onCheckIn,
    required this.checkInLabel,
  });

  final DailyHealthBrief brief;
  final VoidCallback onCheckIn;
  final String checkInLabel;

  @override
  Widget build(BuildContext context) {
    final kynos = context.kynosTheme;

    return KynosCard(
      elevated: true,
      padding: const EdgeInsets.all(Spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: kynos.purple.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(Radius.md),
                ),
                child: Icon(
                  Icons.wb_sunny_outlined,
                  size: 19,
                  color: kynos.purple,
                ),
              ),
              const Gap(Spacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Today',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: kynos.secondaryLabel,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const Gap(Spacing.xs),
                    Text(
                      brief.bodyStateSummary,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (brief.findings.isNotEmpty) ...[
            const Gap(Spacing.sm),
            Text(
              brief.findings.first.observation,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: kynos.secondaryLabel,
                  ),
            ),
          ],
          const Gap(Spacing.md),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.md,
              vertical: Spacing.sm,
            ),
            decoration: BoxDecoration(
              color: kynos.purple.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(Radius.md),
              border: Border.all(
                color: kynos.purple.withValues(alpha: 0.12),
              ),
            ),
            child: Text(
              brief.primaryAction,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          const Gap(Spacing.sm),
          Row(
            children: [
              Expanded(
                child: Text(
                  brief.baselineQuality == BaselineQuality.stable
                      ? 'Based on your baseline'
                      : 'Still learning your baseline',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: kynos.tertiaryLabel,
                      ),
                ),
              ),
              TextButton(
                onPressed: onCheckIn,
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.sm,
                  ),
                ),
                child: Text(checkInLabel),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
