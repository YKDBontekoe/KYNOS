import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:kynos/core/theme/spacing.dart' as tokens;
import 'package:kynos/core/theme/theme.dart';
import 'package:kynos/domain/entities/health_summary.dart';
import 'package:kynos/shared/widgets/kynos_card.dart';
import 'package:kynos/shared/widgets/metric_tile.dart';

/// Compact gait model teaser when calibration is available.
class GaitTeaserCard extends StatelessWidget {
  const GaitTeaserCard({
    super.key,
    required this.coefficients,
    required this.summary,
    this.calibratedAt,
    this.onViewTraining,
  });

  final ({double? b0, double? b1, double? b2}) coefficients;
  final HealthSummary? summary;
  final DateTime? calibratedAt;
  final VoidCallback? onViewTraining;

  @override
  Widget build(BuildContext context) {
    final kynos = context.kynosTheme;

    return Semantics(
      label: 'Gait model summary, tap to view training',
      button: onViewTraining != null,
      child: KynosCard(
        padding: const EdgeInsets.all(tokens.Spacing.md),
        onTap: onViewTraining,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'GAIT MODEL',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                const Spacer(),
                Icon(Icons.lock_rounded, size: 12, color: kynos.tertiaryLabel),
                const Gap(tokens.Spacing.xs),
                Text(
                  'On-device',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const Gap(tokens.Spacing.sm),
            Row(
              children: [
                Expanded(
                  child: MetricTile(
                    label: 'Cadence',
                    value: summary?.cadenceSpm?.round().toString() ?? '—',
                    unit: 'spm',
                    accentColor: kynos.exercise,
                    flat: true,
                  ),
                ),
                const Gap(tokens.Spacing.sm),
                Expanded(
                  child: MetricTile(
                    label: 'Power',
                    value: summary?.runningPowerWatts?.round().toString() ?? '—',
                    unit: 'W',
                    accentColor: kynos.energy,
                    flat: true,
                  ),
                ),
              ],
            ),
            if (calibratedAt != null) ...[
              const Gap(tokens.Spacing.xs),
              Text(
                'Model calibrated · β₁ ${coefficients.b1?.toStringAsFixed(3) ?? '—'}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: kynos.tertiaryLabel,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
