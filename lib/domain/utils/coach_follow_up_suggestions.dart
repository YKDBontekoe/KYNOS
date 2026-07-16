import 'package:kynos/domain/entities/coach/coach_data_source.dart';
import 'package:kynos/domain/entities/coach/coach_seed_topic.dart';

/// Deterministic follow-up suggestions after a coach reply.
abstract final class CoachFollowUpSuggestions {
  static List<String> forContext({
    required Set<CoachDataSource> enabledSources,
    CoachSeedTopic topic = CoachSeedTopic.general,
  }) {
    final suggestions = <String>[];

    if (enabledSources.contains(CoachDataSource.readinessAcwr)) {
      suggestions.add('Explain my readiness score');
    }
    if (enabledSources.contains(CoachDataSource.recentRuns)) {
      suggestions.add('How was my last run?');
    }
    if (enabledSources.contains(CoachDataSource.trainingInsights)) {
      suggestions.add('What should I do in training today?');
    }
    if (enabledSources.contains(CoachDataSource.gaitBiomechanics)) {
      suggestions.add('Tips to improve my gait');
    }

    suggestions.addAll(switch (topic) {
      CoachSeedTopic.postRunDebrief => ['Recovery plan for today'],
      CoachSeedTopic.gait => ['When should I recalibrate gait?'],
      _ => ['Plan my week'],
    });

    return suggestions.take(3).toList();
  }
}
