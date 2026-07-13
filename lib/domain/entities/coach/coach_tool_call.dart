import 'package:freezed_annotation/freezed_annotation.dart';

part 'coach_tool_call.freezed.dart';

/// A structured tool invocation requested by the coach model mid-answer.
@freezed
abstract class CoachToolCall with _$CoachToolCall {
  const factory CoachToolCall({
    required String name,
    @Default(<String, Object?>{}) Map<String, Object?> arguments,
  }) = _CoachToolCall;
}

/// Outcome of executing a [CoachToolCall].
@freezed
abstract class CoachToolResult with _$CoachToolResult {
  const factory CoachToolResult({
    required CoachToolCall toolCall,
    required bool isError,
    required String promptSummary,
    required String displayLabel,
  }) = _CoachToolResult;
}

/// Lifecycle status of a tool call surfaced in the chat UI.
enum CoachToolStatus { running, success, error }

/// A single agentic step (tool call) taken while answering one message.
@freezed
abstract class CoachToolStep with _$CoachToolStep {
  const factory CoachToolStep({
    required String toolName,
    required CoachToolStatus status,
    String? displayLabel,
  }) = _CoachToolStep;
}
