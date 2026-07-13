/// Converts free-form text into an approved, non-identifying intent.
///
/// No original wording, values, names, locations, notes, or symptom text is
/// returned. Structured disclosure-level summaries are handled separately.
abstract final class CloudHealthTextRedactor {
  static const _approvedTopics = <String, List<String>>{
    'sleep and restoration': ['sleep', 'bedtime', 'rest', 'tired'],
    'energy and recovery': ['energy', 'recovery', 'fatigue'],
    'stress and mood': ['stress', 'mood', 'calm', 'anxious'],
    'movement and exercise': ['movement', 'exercise', 'walk', 'run'],
    'personal patterns': ['pattern', 'trend', 'change', 'compare'],
  };

  static bool containsSymptomText(String value) => true;

  static String redact(String value) {
    final lower = value.toLowerCase();
    final topics = _approvedTopics.entries
        .where((entry) => entry.value.any(lower.contains))
        .map((entry) => entry.key)
        .take(2)
        .toList();
    final intent = topics.isEmpty ? 'general wellbeing' : topics.join(' and ');
    return 'The person asks for help with $intent. Their original wording and '
        'any private health or location details were withheld. Use only the '
        'separately authorized local summary.';
  }
}
