import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:kynos/core/constants/app_constants.dart';
import 'package:kynos/core/theme/colors.dart';
import 'package:kynos/core/theme/kynos_theme_extension.dart';
import 'package:kynos/core/theme/spacing.dart' as tokens;
import 'package:kynos/domain/entities/health_summary.dart';
import 'package:kynos/domain/utils/acwr.dart';
import 'package:kynos/shared/widgets/kynos_card.dart';
import 'package:kynos/shared/widgets/kynos_section_header.dart';

/// Training load guardrail card driven by ACWR.
class AcwrGuardrailCard extends StatelessWidget {
  const AcwrGuardrailCard({
    super.key,
    required this.history,
    this.explanation,
  });

  final List<HealthSummary> history;
  final String? explanation;

  @override
  Widget build(BuildContext context) {
    final acwr = computeAcwr(history);
    if (acwr == null) return const SizedBox.shrink();

    final elevated = isAcwrElevated(acwr);
    final kynos = context.kynosTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const KynosSectionHeader(title: 'Load guardrail'),
        const Gap(tokens.Spacing.sm),
        KynosCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    elevated ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                    color: elevated ? KynosColors.move : kynos.stand,
                  ),
                  const Gap(tokens.Spacing.sm),
                  Text(
                    'ACWR ${acwr.toStringAsFixed(2)}',
                    style: kynos.metricValueStyle,
                  ),
                ],
              ),
              const Gap(tokens.Spacing.sm),
              Text(
                acwrRiskLabel(acwr),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              if (explanation != null && explanation!.isNotEmpty) ...[
                const Gap(tokens.Spacing.sm),
                Text(
                  explanation!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: kynos.secondaryLabel,
                      ),
                ),
              ],
              if (elevated)
                Padding(
                  padding: const EdgeInsets.only(top: tokens.Spacing.xs),
                  child: Text(
                    'Safe max: ${AppConstants.acwrSafeMax}',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: kynos.tertiaryLabel,
                        ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
