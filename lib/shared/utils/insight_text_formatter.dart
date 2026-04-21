/// Formats coaching insight text for concise, beginner-friendly UI labels.
abstract final class InsightTextFormatter {
  static const Map<String, String> _plainLanguageTerms = {
    'Resting HR': 'Resting pulse',
    'RHR': 'resting pulse',
    'HRV': 'recovery',
  };

  static String compactChipLabel(String raw, {int maxLength = 26}) {
    final readable = toPlainLanguage(raw);
    final withoutParenthetical = _stripParentheticalSegments(readable).trim();
    if (withoutParenthetical.length <= maxLength) {
      return withoutParenthetical;
    }
    return '${withoutParenthetical.substring(0, maxLength - 1)}…';
  }

  static String toPlainLanguage(String text) {
    var output = text;
    for (final entry in _plainLanguageTerms.entries) {
      output = output.replaceAll(entry.key, entry.value);
    }
    return output;
  }

  /// Removes content wrapped in (...) while preserving the rest of the text.
  static String _stripParentheticalSegments(String text) {
    final buffer = StringBuffer();
    var depth = 0;

    for (final rune in text.runes) {
      final char = String.fromCharCode(rune);
      if (char == '(') {
        depth++;
        continue;
      }
      if (char == ')') {
        if (depth > 0) depth--;
        continue;
      }
      if (depth == 0) {
        buffer.write(char);
      }
    }

    return buffer.toString();
  }
}
