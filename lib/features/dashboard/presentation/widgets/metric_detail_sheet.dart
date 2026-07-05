import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:kynos/core/theme/spacing.dart' as tokens;
import 'package:kynos/core/theme/theme.dart' hide Radius;
import 'package:kynos/domain/entities/health_summary.dart';
import 'package:kynos/features/training/presentation/widgets/chart_placeholder.dart';
import 'package:kynos/features/training/presentation/widgets/hrv_chart.dart';
import 'package:kynos/features/training/presentation/widgets/load_chart.dart';
import 'package:kynos/shared/widgets/kynos_card.dart';

enum MetricDetailKey {
  hrv,
  rhr,
  sleep,
  spo2,
  distance,
  activeCalories,
  exercise,
}

void showMetricDetailSheet(
  BuildContext context, {
  required MetricDetailKey metricKey,
  required List<HealthSummary> history,
  VoidCallback? onViewTraining,
  void Function(String seedMessage)? onAskCoach,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: context.kynosTheme.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(tokens.Radius.lg),
      ),
    ),
    builder: (context) => MetricDetailSheet(
      metricKey: metricKey,
      history: history,
      onViewTraining: onViewTraining,
      onAskCoach: onAskCoach,
    ),
  );
}

class MetricDetailSheet extends StatelessWidget {
  const MetricDetailSheet({
    super.key,
    required this.metricKey,
    required this.history,
    this.onViewTraining,
    this.onAskCoach,
  });

  final MetricDetailKey metricKey;
  final List<HealthSummary> history;
  final VoidCallback? onViewTraining;
  final void Function(String seedMessage)? onAskCoach;

  @override
  Widget build(BuildContext context) {
    final kynos = context.kynosTheme;
    final meta = _metaFor(metricKey);
    final sorted = List<HealthSummary>.from(history)
      ..sort((a, b) => a.date.compareTo(b.date));

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(tokens.Spacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: kynos.separator,
                  borderRadius: BorderRadius.circular(tokens.Radius.full),
                ),
              ),
            ),
            const Gap(tokens.Spacing.md),
            Text(meta.title, style: Theme.of(context).textTheme.titleLarge),
            const Gap(tokens.Spacing.xs),
            Text(meta.caption, style: Theme.of(context).textTheme.bodyMedium),
            const Gap(tokens.Spacing.md),
            KynosCard(
              child: SizedBox(
                height: 200,
                child: sorted.isEmpty
                    ? ChartPlaceholder(label: meta.emptyLabel)
                    : meta.useLoadChart
                    ? LoadChart(points: sorted)
                    : HrvChart(points: sorted),
              ),
            ),
            const Gap(tokens.Spacing.md),
            if (onAskCoach != null)
              TextButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  onAskCoach!(meta.coachSeed);
                },
                icon: const Icon(Icons.chat_bubble_outline, size: 18),
                label: const Text('Ask coach about this'),
              ),
            if (onViewTraining != null)
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onViewTraining!();
                },
                child: const Text('See full trends on Training'),
              ),
          ],
        ),
      ),
    );
  }

  _MetricMeta _metaFor(MetricDetailKey key) => switch (key) {
    MetricDetailKey.hrv => const _MetricMeta(
      title: 'Recovery (HRV)',
      caption: 'Heart rate variability trend over the last week.',
      emptyLabel: 'No HRV data yet',
      coachSeed: 'How should I interpret my HRV trend this week?',
    ),
    MetricDetailKey.rhr => const _MetricMeta(
      title: 'Resting pulse',
      caption: 'Resting heart rate trend over the last week.',
      emptyLabel: 'No resting pulse data yet',
      coachSeed: 'My resting pulse has shifted — what does that mean?',
    ),
    MetricDetailKey.sleep => const _MetricMeta(
      title: 'Sleep',
      caption: 'Sleep duration trend over the last week.',
      emptyLabel: 'No sleep data yet',
      coachSeed: 'Review my sleep trend and suggest recovery adjustments.',
    ),
    MetricDetailKey.spo2 => const _MetricMeta(
      title: 'Blood oxygen',
      caption: 'SpO₂ readings over the last week.',
      emptyLabel: 'No SpO₂ data yet',
      coachSeed: 'Are my SpO₂ readings in a healthy range?',
    ),
    MetricDetailKey.distance => const _MetricMeta(
      title: 'Run distance',
      caption: 'Daily running distance over the last week.',
      emptyLabel: 'No run distance yet',
      coachSeed: 'How is my weekly running volume trending?',
      useLoadChart: true,
    ),
    MetricDetailKey.activeCalories => const _MetricMeta(
      title: 'Active energy',
      caption: 'Active calorie burn over the last week.',
      emptyLabel: 'No calorie data yet',
      coachSeed: 'Is my active energy expenditure balanced with recovery?',
      useLoadChart: true,
    ),
    MetricDetailKey.exercise => const _MetricMeta(
      title: 'Exercise time',
      caption: 'Exercise minutes over the last week.',
      emptyLabel: 'No exercise data yet',
      coachSeed: 'Am I getting enough structured exercise this week?',
    ),
  };
}

class _MetricMeta {
  const _MetricMeta({
    required this.title,
    required this.caption,
    required this.emptyLabel,
    required this.coachSeed,
    this.useLoadChart = false,
  });

  final String title;
  final String caption;
  final String emptyLabel;
  final String coachSeed;
  final bool useLoadChart;
}
