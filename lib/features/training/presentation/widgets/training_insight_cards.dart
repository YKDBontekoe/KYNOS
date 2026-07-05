import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:kynos/core/theme/spacing.dart' as tokens;
import 'package:kynos/domain/entities/insights/insight_confidence.dart';
import 'package:kynos/features/training/presentation/widgets/training_insight_list_card.dart';
import 'package:kynos/features/training/presentation/widgets/training_insight_text_card.dart';
import 'package:kynos/features/training/providers/training_insights_provider.dart';
import 'package:kynos/shared/widgets/kynos_card.dart';
import 'package:kynos/shared/widgets/kynos_loading_line.dart';
import 'package:kynos/shared/widgets/kynos_section_header.dart';
import 'package:logger/logger.dart';

/// AI-generated session intent, adjustments, and debrief cards.
class TrainingInsightsCards extends StatelessWidget {
  const TrainingInsightsCards({super.key, required this.insightsState});

  static final _logger = Logger();

  final AsyncValue<TrainingInsightsState> insightsState;

  @override
  Widget build(BuildContext context) {
    return insightsState.when(
      loading: () => const KynosCard(
        child: KynosLoadingLine(label: 'Building training insights...'),
      ),
      error: (error, stackTrace) {
        _logger.w(
          'Training insights unavailable',
          error: error,
          stackTrace: stackTrace,
        );
        return const SizedBox.shrink();
      },
      data: (state) {
        final insights = state.insights;
        if (insights == null) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const KynosSectionHeader(title: 'Session Intent'),
            const Gap(tokens.Spacing.sm),
            TrainingInsightTextCard(
              title: 'Session Intent',
              icon: Icons.track_changes_rounded,
              text: insights.sessionIntent,
              confidence: insights.confidence.label,
              usedModel: state.usedModel,
            ),
            const Gap(tokens.Spacing.md),
            const KynosSectionHeader(title: 'Adjustment Hints'),
            const Gap(tokens.Spacing.sm),
            TrainingInsightListCard(
              title: 'Adjustments',
              icon: Icons.tune_rounded,
              lines: insights.adjustmentHints,
            ),
            const Gap(tokens.Spacing.md),
            const KynosSectionHeader(title: 'Post-Session Debrief'),
            const Gap(tokens.Spacing.sm),
            TrainingInsightListCard(
              title: 'Debrief',
              icon: Icons.summarize_rounded,
              lines: insights.postSessionDebrief,
              evidence: insights.evidence,
            ),
          ],
        );
      },
    );
  }
}
