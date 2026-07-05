import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:kynos/core/theme/theme.dart';
import 'package:kynos/domain/entities/health_summary.dart';
import 'package:kynos/domain/entities/insights/insight_confidence.dart';
import 'package:kynos/domain/utils/readiness_score.dart';
import 'package:kynos/features/dashboard/presentation/widgets/activity_ring.dart';
import 'package:kynos/features/dashboard/presentation/widgets/hrv_sparkline.dart';
import 'package:kynos/features/dashboard/providers/today_insights_provider.dart';
import 'package:kynos/shared/widgets/kynos_card.dart';
import 'package:kynos/shared/widgets/kynos_loading_line.dart';

/// Readiness score card with activity ring and confidence badge.
class ReadinessCard extends StatelessWidget {
  const ReadinessCard({
    super.key,
    required this.summaryAsync,
    required this.todayInsightsState,
    this.history = const [],
  });

  final AsyncValue<HealthSummary?> summaryAsync;
  final AsyncValue<TodayInsightsState> todayInsightsState;
  final List<HealthSummary> history;

  @override
  Widget build(BuildContext context) {
    return summaryAsync.when(
      loading: () => const KynosCard(
        child: KynosLoadingLine(label: 'Loading readiness...'),
      ),
      error: (_, _) => KynosCard(
        child: Text(
          'Could not load health data.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
      data: (summary) => _ReadinessCardContent(
        summary: summary,
        todayInsightsState: todayInsightsState,
        history: history,
      ),
    );
  }
}

class _ReadinessCardContent extends StatelessWidget {
  const _ReadinessCardContent({
    required this.summary,
    required this.todayInsightsState,
    required this.history,
  });

  final HealthSummary? summary;
  final AsyncValue<TodayInsightsState> todayInsightsState;
  final List<HealthSummary> history;

  @override
  Widget build(BuildContext context) {
    final kynos = context.kynosTheme;
    final score = readinessScore(summary);
    final dimensions = readinessDimensions(summary);
    final ringColors = [
      kynos.move,
      kynos.exercise,
      kynos.stand,
      kynos.purple,
    ];

    return KynosCard(
      padding: const EdgeInsets.all(Spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ActivityRing(
                ringProgresses: dimensions.ringProgresses,
                size: 82,
                strokeWidth: 8,
                colors: ringColors,
              ),
              const Gap(Spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'READINESS',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    const Gap(Spacing.xs),
                    Text(
                      summary == null ? '—' : score.round().toString(),
                      style: kynos.metricValueStyle.copyWith(
                        fontSize: 38,
                        fontWeight: FontWeight.w800,
                        color: summary == null
                            ? kynos.secondaryLabel
                            : kynos.purple,
                        height: 1,
                        letterSpacing: -1,
                      ),
                    ),
                    const Gap(Spacing.xs),
                    Text(
                      summary == null
                          ? 'Connect health data to calculate a real readiness score.'
                          : _readinessBrief(
                              score: score,
                              todayInsightsState: todayInsightsState,
                            ),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (history.isNotEmpty) ...[
            const Gap(Spacing.sm),
            const Divider(height: 1),
            const Gap(Spacing.sm),
            Text(
              '7-DAY RECOVERY',
              style: Theme.of(context).textTheme.labelSmall,
            ),
            const Gap(Spacing.xs),
            HrvSparkline(history: history),
          ],
          ConfidenceBadgeRow(todayInsightsState: todayInsightsState),
        ],
      ),
    );
  }
}

String _readinessBrief({
  required double score,
  required AsyncValue<TodayInsightsState> todayInsightsState,
}) {
  final todayInsights = todayInsightsState.value?.insights;
  if (todayInsights != null && todayInsights.readinessBrief.isNotEmpty) {
    return todayInsights.readinessBrief;
  }
  return readinessSummary(score);
}

/// Confidence and model-source badge below the readiness score.
class ConfidenceBadgeRow extends StatelessWidget {
  const ConfidenceBadgeRow({super.key, required this.todayInsightsState});

  final AsyncValue<TodayInsightsState> todayInsightsState;

  @override
  Widget build(BuildContext context) {
    final kynos = context.kynosTheme;

    return todayInsightsState.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (state) {
        final insights = state.insights;
        if (insights == null) return const SizedBox.shrink();
        return Column(
          children: [
            const Gap(Spacing.sm),
            const Divider(height: 1),
            const Gap(Spacing.sm),
            Row(
              children: [
                Icon(
                  Icons.verified_rounded,
                  size: 14,
                  color: kynos.purple.withValues(alpha: 0.75),
                ),
                const Gap(Spacing.sm),
                Text(
                  'Confidence: ${insights.confidence.label}${state.usedModel ? ' • Gemma refined' : ' • Rule-based'}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: kynos.tertiaryLabel,
                      ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
