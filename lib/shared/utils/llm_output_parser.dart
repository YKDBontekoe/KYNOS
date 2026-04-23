/// Parses key-value text output produced by the on-device LLM.
///
/// Expected format (one key per line):
///   KEY: value
///   LIST_KEY: item1 | item2 | item3
abstract final class LlmOutputParser {
  /// Returns the trimmed value after `key:` on a matching line, or null.
  static String? take(String raw, String key) {
    final match = RegExp('$key\\s*:(.*)', multiLine: true).firstMatch(raw);
    return match?.group(1)?.trim();
  }

  /// Splits a pipe-delimited value into a list, dropping empty items.
  static List<String> splitList(String? value, {int max = 3}) {
    if (value == null || value.isEmpty) return const [];
    return value
        .split('|')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .take(max)
        .toList();
  }
}
