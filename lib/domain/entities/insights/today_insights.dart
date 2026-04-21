import 'package:kynos/domain/entities/insights/insight_confidence.dart';

class TodayInsights {
  const TodayInsights({
    required this.readinessBrief,
    required this.whatChanged,
    required this.riskFlags,
    required this.actionNow,
    required this.actionTonight,
    required this.evidence,
    required this.confidence,
  });

  final String readinessBrief;
  final List<String> whatChanged;
  final List<String> riskFlags;
  final String actionNow;
  final String actionTonight;
  final List<String> evidence;
  final InsightConfidence confidence;

  TodayInsights copyWith({
    String? readinessBrief,
    List<String>? whatChanged,
    List<String>? riskFlags,
    String? actionNow,
    String? actionTonight,
    List<String>? evidence,
    InsightConfidence? confidence,
  }) {
    return TodayInsights(
      readinessBrief: readinessBrief ?? this.readinessBrief,
      whatChanged: whatChanged ?? this.whatChanged,
      riskFlags: riskFlags ?? this.riskFlags,
      actionNow: actionNow ?? this.actionNow,
      actionTonight: actionTonight ?? this.actionTonight,
      evidence: evidence ?? this.evidence,
      confidence: confidence ?? this.confidence,
    );
  }
}
