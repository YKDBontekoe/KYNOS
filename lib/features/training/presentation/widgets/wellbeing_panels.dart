import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:kynos/core/theme/theme.dart';
import 'package:kynos/domain/entities/health/health_coach_models.dart';
import 'package:kynos/shared/providers/health_coach_providers.dart';
import 'package:kynos/shared/widgets/kynos_card.dart';
import 'package:kynos/shared/widgets/kynos_loading_line.dart';

class DailyHealthOverview extends StatelessWidget {
  const DailyHealthOverview({super.key, required this.brief});

  final AsyncValue<DailyHealthBrief> brief;

  @override
  Widget build(BuildContext context) => brief.when(
    loading: () => const KynosCard(
      child: KynosLoadingLine(label: 'Building today’s health brief…'),
    ),
    error: (_, _) => const KynosCard(
      child: Text('Today’s health brief is temporarily unavailable.'),
    ),
    data: (value) => KynosCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value.bodyStateSummary,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const Gap(Spacing.sm),
          Text(value.primaryAction),
          const Gap(Spacing.sm),
          Text(
            value.baselineQuality == BaselineQuality.stable
                ? 'Compared with your personal 28-day baseline'
                : 'Learning your baseline · more days will improve confidence',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: context.kynosTheme.secondaryLabel,
            ),
          ),
        ],
      ),
    ),
  );
}

class CheckInHistoryPanel extends StatelessWidget {
  const CheckInHistoryPanel({super.key, required this.checkIns});

  final List<HealthCheckIn> checkIns;

  @override
  Widget build(BuildContext context) {
    if (checkIns.isEmpty) {
      return const KynosCard(
        child: Text(
          'Complete a daily check-in to connect body signals with how you feel.',
        ),
      );
    }
    return KynosCard(
      child: Column(
        children: checkIns.take(7).map((item) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: Spacing.xs),
            child: Row(
              children: [
                Expanded(child: Text('${item.date.day}/${item.date.month}')),
                Text('Energy ${item.energy}/5'),
                const Gap(Spacing.md),
                Text('Stress ${item.stress}/5'),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class WellbeingExperimentsPanel extends ConsumerWidget {
  const WellbeingExperimentsPanel({super.key, required this.experiments});

  final List<WellbeingExperiment> experiments;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (experiments.isEmpty) {
      return const KynosCard(
        child: Text(
          'Ask KYNOS to propose a small wellbeing experiment. Nothing starts without your confirmation.',
        ),
      );
    }
    return Column(
      children: experiments.take(5).map((experiment) {
        return Padding(
          padding: const EdgeInsets.only(bottom: Spacing.sm),
          child: KynosCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        experiment.title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    Text(experiment.status.name),
                  ],
                ),
                const Gap(Spacing.xs),
                Text(experiment.action),
                const Gap(Spacing.xs),
                Text(
                  '${experiment.durationDays} days · ${experiment.logs.length} recorded',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (experiment.status == ExperimentStatus.active) ...[
                  const Gap(Spacing.sm),
                  Wrap(
                    spacing: Spacing.sm,
                    children: [
                      FilledButton.tonal(
                        onPressed: () => ref
                            .read(healthCoachDataProvider.notifier)
                            .logExperiment(id: experiment.id, adhered: true),
                        child: const Text('Done today'),
                      ),
                      TextButton(
                        onPressed: () => ref
                            .read(healthCoachDataProvider.notifier)
                            .logExperiment(id: experiment.id, adhered: false),
                        child: const Text('Not today'),
                      ),
                      TextButton(
                        onPressed: () => ref
                            .read(healthCoachDataProvider.notifier)
                            .cancelExperiment(experiment.id),
                        child: const Text('End experiment'),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
