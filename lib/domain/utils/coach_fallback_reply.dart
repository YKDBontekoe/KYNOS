import 'package:kynos/domain/entities/health_summary.dart';
import 'package:kynos/domain/utils/readiness_score.dart';

/// Deterministic coach reply when on-device Gemma is unavailable.
abstract final class CoachFallbackReply {
  static String forRecoveryQuestion({
    required String userMessage,
    List<HealthSummary>? healthContext,
  }) {
    final sorted = List<HealthSummary>.from(healthContext ?? const [])
      ..sort((a, b) => b.date.compareTo(a.date));
    final today = sorted.isEmpty ? null : sorted.first;
    final score = readinessScore(today);
    final summary = readinessSummaryBrief(score);

    final lower = userMessage.toLowerCase();
    if (lower.contains('recovery') ||
        lower.contains('ready') ||
        lower.contains('rest')) {
      return 'I could not reach the on-device model, but your latest metrics '
          'suggest: $summary '
          'Keep today easy if HRV or sleep look off; add strides only if you feel fresh.';
    }

    return 'The on-device coach model is unavailable right now. '
        'Based on your recent metrics: $summary '
        'Try again shortly — we will automatically use a safer inference mode.';
  }
}
