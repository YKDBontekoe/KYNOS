import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:kynos/core/theme/theme.dart';
import 'package:kynos/domain/entities/coach/today_directive.dart';
import 'package:kynos/domain/entities/coach/training_plan.dart';
import 'package:kynos/shared/providers/training_plan_providers.dart';
import 'package:kynos/shared/widgets/kynos_card.dart';
import 'package:kynos/shared/widgets/kynos_chip.dart';

class TodayDirectiveCard extends ConsumerWidget {
  const TodayDirectiveCard({
    super.key,
    required this.directive,
    required this.onAsk,
  });

  final TodayDirective directive;
  final ValueChanged<String> onAsk;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kynos = context.kynosTheme;
    final isBuildCta = directive.source == TodayDirectiveSource.buildPlanCta;
    final isDone = directive.adherence == PlanAdherenceStatus.done;
    final isSkipped = directive.adherence == PlanAdherenceStatus.skipped;

    return KynosCard(
      elevated: true,
      padding: const EdgeInsets.all(Spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Today’s session',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: kynos.secondaryLabel,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const Gap(Spacing.xs),
          Text(
            directive.headline,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.4,
                ),
          ),
          const Gap(Spacing.xs),
          Text(
            directive.detail,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: kynos.secondaryLabel,
                ),
          ),
          if (directive.rationale.isNotEmpty) ...[
            const Gap(Spacing.sm),
            Wrap(
              spacing: Spacing.xs,
              runSpacing: Spacing.xs,
              children: [
                for (final reason in directive.rationale.take(3))
                  KynosChip(label: reason),
              ],
            ),
          ],
          const Gap(Spacing.md),
          if (isBuildCta)
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => onAsk(directive.promptSeed),
                child: Text(directive.ctaLabel ?? 'Build my plan'),
              ),
            )
          else ...[
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: isDone
                        ? null
                        : () => ref
                            .read(trainingPlanDataProvider.notifier)
                            .markDone(),
                    child: Text(isDone ? 'Done' : 'Mark done'),
                  ),
                ),
                const Gap(Spacing.sm),
                Expanded(
                  child: OutlinedButton(
                    onPressed: isSkipped
                        ? null
                        : () => ref
                            .read(trainingPlanDataProvider.notifier)
                            .markSkipped(),
                    child: Text(isSkipped ? 'Skipped' : 'Skip'),
                  ),
                ),
              ],
            ),
            const Gap(Spacing.sm),
            TextButton.icon(
              onPressed: () => onAsk(directive.promptSeed),
              icon: const Icon(Icons.help_outline_rounded, size: 18),
              label: const Text('Why / Ask'),
            ),
          ],
        ],
      ),
    );
  }
}
