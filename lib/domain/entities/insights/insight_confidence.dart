enum InsightConfidence { high, medium, low }

extension InsightConfidenceLabel on InsightConfidence {
  String get label {
    switch (this) {
      case InsightConfidence.high:
        return 'High';
      case InsightConfidence.medium:
        return 'Medium';
      case InsightConfidence.low:
        return 'Low';
    }
  }
}
