import 'package:kynos/core/errors/failures.dart';
import 'package:kynos/domain/entities/insights/today_insights.dart';
import 'package:kynos/domain/repositories/ai_coach_repository.dart';
import 'package:kynos/domain/repositories/ai_model_repository.dart';
import 'package:kynos/domain/repositories/health_repository.dart';
import 'package:kynos/domain/usecases/insights/today_insights_deterministic.dart';
import 'package:kynos/domain/usecases/insights/today_insights_model_refiner.dart';

class GenerateTodayInsightsUseCase {
  const GenerateTodayInsightsUseCase({
    required HealthRepository healthRepository,
    required AiCoachRepository aiCoachRepository,
    required AiModelRepository aiModelRepository,
  }) : _healthRepository = healthRepository,
       _aiCoachRepository = aiCoachRepository,
       _aiModelRepository = aiModelRepository;

  final HealthRepository _healthRepository;
  final AiCoachRepository _aiCoachRepository;
  final AiModelRepository _aiModelRepository;

  Future<({TodayInsights? insights, Failure? failure, bool usedModel})>
  call() async {
    final todayResult = await _healthRepository.getToday();
    if (todayResult.failure != null) {
      return (insights: null, failure: todayResult.failure, usedModel: false);
    }

    final today = todayResult.summary;
    if (today == null) {
      return (
        insights: null,
        failure: const HealthDataFailure('No health summary for today.'),
        usedModel: false,
      );
    }

    final historyResult = await _healthRepository.getSummaries(days: 14);
    if (historyResult.failure != null) {
      return (insights: null, failure: historyResult.failure, usedModel: false);
    }

    final sortedHistory = historyResult.summaries.toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    final yesterday = findYesterdaySummary(sortedHistory, today.date);

    final base = buildTodayInsightsDeterministic(
      today: today,
      yesterday: yesterday,
    );

    final refiner = TodayInsightsModelRefiner(
      aiCoachRepository: _aiCoachRepository,
      aiModelRepository: _aiModelRepository,
    );
    final refined = await refiner.refine(
      baseline: base,
      today: today,
      yesterday: yesterday,
      history: sortedHistory,
    );

    return (
      insights: refined ?? base,
      failure: null,
      usedModel: refined != null,
    );
  }
}
