import 'package:kynos/domain/entities/insights/insight_confidence.dart';

class TrainingInsights {
  const TrainingInsights({
    required this.sessionIntent,
    required this.adjustmentHints,
    required this.postSessionDebrief,
    required this.evidence,
    required this.confidence,
  });

  final String sessionIntent;
  final List<String> adjustmentHints;
  final List<String> postSessionDebrief;
  final List<String> evidence;
  final InsightConfidence confidence;

  TrainingInsights copyWith({
    String? sessionIntent,
    List<String>? adjustmentHints,
    List<String>? postSessionDebrief,
    List<String>? evidence,
    InsightConfidence? confidence,
  }) {
    return TrainingInsights(
      sessionIntent: sessionIntent ?? this.sessionIntent,
      adjustmentHints: adjustmentHints ?? this.adjustmentHints,
      postSessionDebrief: postSessionDebrief ?? this.postSessionDebrief,
      evidence: evidence ?? this.evidence,
      confidence: confidence ?? this.confidence,
    );
  }
}
