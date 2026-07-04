import 'package:flutter/foundation.dart';
import 'package:kynos/domain/entities/insights/insight_confidence.dart';
import 'package:kynos/domain/entities/insights/today_insights.dart';
import 'package:kynos/shared/providers/ai_insights_usecase_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'today_insights_provider.g.dart';

class TodayInsightsState {
  const TodayInsightsState({
    required this.insights,
    required this.usedModel,
    required this.failureMessage,
  });

  final TodayInsights? insights;
  final bool usedModel;
  final String? failureMessage;
}

@riverpod
Future<TodayInsightsState> todayInsightsState(TodayInsightsStateRef ref) async {
  if (kIsWeb) {
    return const TodayInsightsState(
      insights: TodayInsights(
        readinessBrief:
            'Preview mode: connect HealthKit on iOS for live readiness.',
        whatChanged: <String>[
          'Waiting for device sync to compare against yesterday.',
          'No wearable metrics in preview mode.',
        ],
        riskFlags: <String>[
          'Low data completeness: risk scoring is conservative.',
        ],
        actionNow: 'Use an easy 20-30 min aerobic run and monitor RPE.',
        actionTonight:
            'Prioritise sleep consistency to improve tomorrow readiness confidence.',
        evidence: <String>['Preview mode', 'No HealthKit bridge on web'],
        confidence: InsightConfidence.low,
      ),
      usedModel: false,
      failureMessage: null,
    );
  }

  final useCase = ref.watch(generateTodayInsightsUseCaseProvider);
  final result = await useCase();

  return TodayInsightsState(
    insights: result.insights,
    usedModel: result.usedModel,
    failureMessage: result.failure?.message,
  );
}
