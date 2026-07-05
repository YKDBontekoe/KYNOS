import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kynos/core/theme/app_theme.dart';
import 'package:kynos/core/theme/spacing.dart' as tokens;
import 'package:kynos/domain/entities/health_summary.dart';
import 'package:kynos/domain/entities/insights/insight_confidence.dart';
import 'package:kynos/domain/utils/readiness_score.dart';
import 'package:kynos/features/dashboard/presentation/widgets/activity_ring.dart';
import 'package:kynos/features/dashboard/providers/today_insights_provider.dart';
import 'package:kynos/shared/widgets/kynos_card.dart';

/// Readiness score card with activity ring and confidence badge.
class ReadinessCard extends StatelessWidget {
  const ReadinessCard({
    super.key,
    required this.summary,
    required this.todayInsightsState,
  });

  final HealthSummary? summary;
  final AsyncValue<TodayInsightsState> todayInsightsState;

  @override
  Widget build(BuildContext context) {
    final score = readinessScore(summary);

    return KynosCard(
      padding: const EdgeInsets.all(tokens.Spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ActivityRing(
                progress: score / 100,
                size: 82,
                strokeWidth: 8,
                colors: const [
                  AppTheme.move,
                  AppTheme.exercise,
                  AppTheme.stand,
                ],
              ),
              const Gap(tokens.Spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'READINESS',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    const Gap(tokens.Spacing.xs),
                    Text(
                      summary == null ? '—' : score.round().toString(),
                      style: GoogleFonts.inter(
                        fontSize: 38,
                        fontWeight: FontWeight.w800,
                        color: summary == null
                            ? AppTheme.secondaryLabel
                            : AppTheme.purple,
                        height: 1,
                        letterSpacing: -1,
                      ),
                    ),
                    const Gap(tokens.Spacing.xs),
                    Text(
                      summary == null
                          ? 'Connect HealthKit to calculate a real readiness score.'
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
    return todayInsightsState.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (state) {
        final insights = state.insights;
        if (insights == null) return const SizedBox.shrink();
        return Column(
          children: [
            const Gap(tokens.Spacing.sm),
            const Divider(height: 1),
            const Gap(tokens.Spacing.sm),
            Row(
              children: [
                Icon(
                  Icons.verified_rounded,
                  size: 14,
                  color: AppTheme.purple.withValues(alpha: 0.75),
                ),
                const Gap(tokens.Spacing.sm),
                Text(
                  'Confidence: ${insights.confidence.label}${state.usedModel ? ' • Gemma refined' : ' • Rule-based'}',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppTheme.tertiaryLabel,
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
