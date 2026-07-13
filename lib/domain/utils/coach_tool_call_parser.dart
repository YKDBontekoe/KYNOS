import 'dart:convert';

import 'package:kynos/domain/entities/coach/coach_tool_call.dart';

/// Parses ReAct-style `TOOL_CALL: {...}` directives from coach model output.
///
/// The on-device and cloud system prompts (see [CoachAgentToolCatalog])
/// instruct the model to emit exactly one such line when it needs more data
/// instead of answering directly.
abstract final class CoachToolCallParser {
  static const _marker = 'TOOL_CALL';

  /// Parses [text] for a tool-call directive, or returns null if absent or malformed.
  static CoachToolCall? tryParse(String text) {
    final braceStart = _braceStartAfterMarker(text);
    if (braceStart == -1) return null;

    final braceEnd = _matchingBraceEnd(text, braceStart);
    if (braceEnd == -1) return null;

    try {
      final decoded = jsonDecode(text.substring(braceStart, braceEnd + 1));
      if (decoded is! Map) return null;
      final name = decoded['name'];
      if (name is! String || name.trim().isEmpty) return null;

      final rawArgs = decoded['arguments'];
      final arguments = rawArgs is Map
          ? rawArgs.map((key, value) => MapEntry(key.toString(), value))
          : <String, dynamic>{};
      return CoachToolCall(name: name.trim(), arguments: arguments);
    } on FormatException {
      return null;
    }
  }

  /// Removes any tool-call directive that leaked into a user-visible answer.
  static String stripToolCallMarkup(String text) {
    final markerIndex = text.indexOf(_marker);
    if (markerIndex == -1) return text;

    final braceStart = _braceStartAfterMarker(text);
    final braceEnd =
        braceStart == -1 ? -1 : _matchingBraceEnd(text, braceStart);

    final before = text.substring(0, markerIndex).trim();
    final after = braceEnd == -1 ? '' : text.substring(braceEnd + 1).trim();
    if (before.isNotEmpty && after.isNotEmpty) return '$before\n\n$after';
    return before.isNotEmpty ? before : after;
  }

  /// True once buffered [partial] output can no longer become a tool-call
  /// directive, so the caller may safely start streaming it live to the UI.
  static bool isDefinitelyNotToolCall(String partial) {
    final trimmed = partial.trimLeft();
    if (trimmed.isEmpty) return false;
    final compareLen =
        trimmed.length < _marker.length ? trimmed.length : _marker.length;
    final candidate = trimmed.substring(0, compareLen).toUpperCase();
    return candidate != _marker.substring(0, compareLen);
  }

  static int _braceStartAfterMarker(String text) {
    final markerIndex = text.indexOf(_marker);
    if (markerIndex == -1) return -1;
    final colonIndex = text.indexOf(':', markerIndex);
    if (colonIndex == -1) return -1;
    return text.indexOf('{', colonIndex);
  }

  static int _matchingBraceEnd(String text, int openIndex) {
    var depth = 0;
    var inString = false;
    var escapeNext = false;
    for (var i = openIndex; i < text.length; i++) {
      final char = text[i];
      if (escapeNext) {
        escapeNext = false;
        continue;
      }
      if (char == r'\') {
        escapeNext = true;
        continue;
      }
      if (char == '"') {
        inString = !inString;
        continue;
      }
      if (inString) continue;
      if (char == '{') depth++;
      if (char == '}') {
        depth--;
        if (depth == 0) return i;
      }
    }
    return -1;
  }
}
