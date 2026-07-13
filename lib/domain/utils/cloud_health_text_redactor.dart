/// Removes free-form symptom wording before an explicitly selected cloud turn.
///
/// Structured, disclosure-level health summaries are handled separately. This
/// guard prevents notes or symptom descriptions from being copied into a cloud
/// prompt accidentally.
abstract final class CloudHealthTextRedactor {
  static final _symptomPattern = RegExp(
    r'\b(pain|dizz(?:y|iness)|nausea|fever|cough|breath(?:ing)?|faint(?:ed|ing)?|'
    r'weakness|bleed(?:ing)?|vomit(?:ing)?|headache|migraine|palpitation|'
    r'injur(?:y|ed)|sick|unwell)\b',
    caseSensitive: false,
  );

  static bool containsSymptomText(String value) =>
      _symptomPattern.hasMatch(value);

  static String redact(String value) {
    if (!containsSymptomText(value)) return value;
    return 'The person included private symptom details, which were withheld '
        'from the cloud prompt. Give only general, non-diagnostic guidance and '
        'encourage appropriate professional support.';
  }
}
