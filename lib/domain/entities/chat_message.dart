import 'package:kynos/domain/entities/ai_inference_backend.dart';
import 'package:meta/meta.dart';

enum MessageRole { user, assistant }

@immutable
class ChatMessage {
  final String id;
  final MessageRole role;
  final String content;
  final DateTime timestamp;

  /// True while the background isolate is still streaming tokens for this message.
  final bool isStreaming;

  /// True when inference failed for this assistant message.
  final bool hasError;

  /// Original user prompt preserved for per-message retry.
  final String? userPromptForRetry;

  /// Backend used for the last inference attempt on this message.
  final AiInferenceBackend? attemptedBackend;

  /// Enabled coach data sources at send time (for per-message audit).
  final List<String>? contextSnapshotIds;

  const ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
    this.isStreaming = false,
    this.hasError = false,
    this.userPromptForRetry,
    this.attemptedBackend,
    this.contextSnapshotIds,
  });

  ChatMessage copyWith({
    String? content,
    bool? isStreaming,
    bool? hasError,
    String? userPromptForRetry,
    AiInferenceBackend? attemptedBackend,
    List<String>? contextSnapshotIds,
  }) {
    return ChatMessage(
      id: id,
      role: role,
      content: content ?? this.content,
      timestamp: timestamp,
      isStreaming: isStreaming ?? this.isStreaming,
      hasError: hasError ?? this.hasError,
      userPromptForRetry: userPromptForRetry ?? this.userPromptForRetry,
      attemptedBackend: attemptedBackend ?? this.attemptedBackend,
      contextSnapshotIds: contextSnapshotIds ?? this.contextSnapshotIds,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatMessage &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          role == other.role &&
          content == other.content &&
          timestamp == other.timestamp &&
          isStreaming == other.isStreaming &&
          hasError == other.hasError &&
          userPromptForRetry == other.userPromptForRetry &&
          attemptedBackend == other.attemptedBackend &&
          _listEquals(contextSnapshotIds, other.contextSnapshotIds);

  @override
  int get hashCode => Object.hash(
        id,
        role,
        content,
        timestamp,
        isStreaming,
        hasError,
        userPromptForRetry,
        attemptedBackend,
        contextSnapshotIds == null
            ? null
            : Object.hashAll(contextSnapshotIds!),
      );
}

bool _listEquals<T>(List<T>? a, List<T>? b) {
  if (identical(a, b)) return true;
  if (a == null || b == null) return a == b;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
