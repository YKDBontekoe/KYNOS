import 'package:kynos/core/utils/readiness_calculator.dart';
import 'package:kynos/infrastructure/ai/ai_infrastructure_providers.dart';
import 'package:kynos/features/dashboard/providers/health_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'coach_insight_provider.g.dart';

@riverpod
Stream<String> coachInsight(CoachInsightRef ref) async* {
  final healthSummaryAsync = ref.watch(healthSummaryProvider);

  if (healthSummaryAsync.isLoading || healthSummaryAsync.hasError) {
    yield '';
    return;
  }

  final summary = healthSummaryAsync.value;
  if (summary == null) {
    yield 'Connect HealthKit to get your daily insight.';
    return;
  }

  final readiness = calculateReadiness(summary);
  final sleep = summary.sleepHours?.toStringAsFixed(1) ?? 'unknown';
  final hrv = summary.hrvMs?.round().toString() ?? 'unknown';

  final prompt =
      '''
You are KYNOS, an elite AI running coach. Write a very brief, 1-2 sentence personalized daily insight for the athlete.
Their Readiness score today is $readiness/100 (based on ${sleep}h sleep and ${hrv}ms HRV).
Do not greet them. Do not use quotes. Keep it actionable and punchy.
''';

  final aiRepository = ref.watch(aiCoachRepositoryProvider);

  String fullResponse = '';

  try {
    await for (final chunk in aiRepository.chat(userMessage: prompt)) {
      fullResponse += chunk;
      yield fullResponse;
    }
  } catch (e) {
    yield 'Ready to run. Focus on your form today.'; // Fallback
  }
}
