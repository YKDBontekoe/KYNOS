import 'package:flutter/foundation.dart';
import 'package:kynos/domain/entities/insights/insight_confidence.dart';
import 'package:kynos/domain/entities/insights/training_insights.dart';
import 'package:kynos/shared/providers/ai_insights_usecase_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'training_insights_provider.g.dart';

class TrainingInsightsState {
  const TrainingInsightsState({
    required this.insights,
    required this.usedModel,
    required this.failureMessage,
  });

  final TrainingInsights? insights;
  final bool usedModel;
  final String? failureMessage;
}

@riverpod
Future<TrainingInsightsState> trainingInsightsState(
  Ref ref,
) async {
  if (kIsWeb) {
    return const TrainingInsightsState(
      insights: TrainingInsights(
        sessionIntent: 'Intent: recovery-biased preview day. Keep RPE 4-6.',
        adjustmentHints: <String>[
          'If breathing rises early, reduce one interval block.',
          'Extend rest 30-60 seconds when form quality drops.',
          'Keep cadence stable before adding pace.',
        ],
        postSessionDebrief: <String>[
          'Live debrief unlocks after HealthKit run sync on device.',
        ],
        evidence: <String>[
          'Preview mode',
          'No on-device health context on web',
        ],
        confidence: InsightConfidence.low,
      ),
      usedModel: false,
      failureMessage: null,
    );
  }

  final useCase = ref.watch(generateTrainingInsightsUseCaseProvider);
  final result = await useCase();

  return TrainingInsightsState(
    insights: result.insights,
    usedModel: result.usedModel,
    failureMessage: result.failure?.message,
  );
}
