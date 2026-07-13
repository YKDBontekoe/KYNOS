import 'package:meta/meta.dart';

/// A structured tool invocation requested by the coach model mid-answer.
@immutable
class CoachToolCall {
  const CoachToolCall({required this.name, this.arguments = const {}});

  final String name;
  final Map<String, dynamic> arguments;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CoachToolCall &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          _mapEquals(arguments, other.arguments);

  @override
  int get hashCode =>
      Object.hash(name, Object.hashAllUnordered(arguments.keys));
}

bool _mapEquals(Map<String, dynamic> a, Map<String, dynamic> b) {
  if (a.length != b.length) return false;
  for (final entry in a.entries) {
    if (!b.containsKey(entry.key) || b[entry.key] != entry.value) return false;
  }
  return true;
}

/// Outcome of executing a [CoachToolCall].
@immutable
class CoachToolResult {
  const CoachToolResult({
    required this.call,
    required this.isError,
    required this.promptSummary,
    required this.displayLabel,
  });

  /// The tool call this result answers.
  final CoachToolCall call;

  /// Whether the tool failed (bad arguments, disabled data source, etc.).
  final bool isError;

  /// Compact text fed back to the model as the tool's output.
  final String promptSummary;

  /// Short human-readable label shown as a chip in the chat UI.
  final String displayLabel;
}

/// Lifecycle status of a tool call surfaced in the chat UI.
enum CoachToolStatus { running, success, error }

/// A single agentic step (tool call) taken while answering one message.
@immutable
class CoachToolStep {
  const CoachToolStep({
    required this.toolName,
    required this.status,
    this.displayLabel,
  });

  final String toolName;
  final CoachToolStatus status;
  final String? displayLabel;

  CoachToolStep copyWith({CoachToolStatus? status, String? displayLabel}) {
    return CoachToolStep(
      toolName: toolName,
      status: status ?? this.status,
      displayLabel: displayLabel ?? this.displayLabel,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CoachToolStep &&
          runtimeType == other.runtimeType &&
          toolName == other.toolName &&
          status == other.status &&
          displayLabel == other.displayLabel;

  @override
  int get hashCode => Object.hash(toolName, status, displayLabel);
}
