import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:kynos/core/theme/theme.dart';
import 'package:kynos/domain/entities/health/health_coach_models.dart';
import 'package:kynos/shared/widgets/kynos_card.dart';

class WellbeingQuestPanel extends StatelessWidget {
  const WellbeingQuestPanel({super.key, required this.experiments});

  final List<WellbeingExperiment> experiments;

  @override
  Widget build(BuildContext context) {
    final active = experiments
        .where((item) => item.status == ExperimentStatus.active)
        .take(3)
        .toList();
    return KynosCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            active.isEmpty
                ? 'Your journey values balance'
                : 'Active wellbeing quests',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const Gap(Spacing.xs),
          if (active.isEmpty)
            const Text(
              'Check-ins, gentle movement, reflection, sleep consistency, and appropriate rest all count as progress.',
            )
          else
            for (final experiment in active) ...[
              Text('• ${experiment.title}: ${experiment.action}'),
              const Gap(Spacing.xs),
            ],
          const Gap(Spacing.sm),
          Text(
            'KYNOS never rewards biometric values, excessive exercise, or ignoring discomfort.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: context.kynosTheme.secondaryLabel,
            ),
          ),
        ],
      ),
    );
  }
}
