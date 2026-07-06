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

  const ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
    this.isStreaming = false,
    this.hasError = false,
    this.userPromptForRetry,
  });

  ChatMessage copyWith({
    String? content,
    bool? isStreaming,
    bool? hasError,
    String? userPromptForRetry,
  }) {
    return ChatMessage(
      id: id,
      role: role,
      content: content ?? this.content,
      timestamp: timestamp,
      isStreaming: isStreaming ?? this.isStreaming,
      hasError: hasError ?? this.hasError,
      userPromptForRetry: userPromptForRetry ?? this.userPromptForRetry,
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
          userPromptForRetry == other.userPromptForRetry;

  @override
  int get hashCode => Object.hash(
        id,
        role,
        content,
        timestamp,
        isStreaming,
        hasError,
        userPromptForRetry,
      );
}
