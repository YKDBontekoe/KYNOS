import 'package:kynos/domain/entities/chat_message.dart';
import 'package:kynos/domain/entities/coach/coach_chat_seed.dart';
import 'package:kynos/domain/entities/coach/coach_conversation_settings.dart';

/// A persisted coach chat thread with messages and per-thread settings.
class CoachConversation {
  CoachConversation({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    this.messages = const [],
    CoachConversationSettings? settings,
    this.seed,
    this.isPinned = false,
    this.isArchived = false,
  }) : settings = settings ?? CoachConversationSettings.defaults;

  final String id;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<ChatMessage> messages;
  final CoachConversationSettings settings;
  final CoachChatSeedData? seed;
  final bool isPinned;
  final bool isArchived;

  String? get lastMessagePreview {
    for (final message in messages.reversed) {
      if (message.content.trim().isNotEmpty && !message.isStreaming) {
        final text = message.content.trim();
        return text.length > 80 ? '${text.substring(0, 80)}…' : text;
      }
    }
    return null;
  }

  CoachConversation copyWith({
    String? title,
    DateTime? updatedAt,
    List<ChatMessage>? messages,
    CoachConversationSettings? settings,
    CoachChatSeedData? seed,
    bool? isPinned,
    bool? isArchived,
    bool clearSeed = false,
  }) {
    return CoachConversation(
      id: id,
      title: title ?? this.title,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      messages: messages ?? this.messages,
      settings: settings ?? this.settings,
      seed: clearSeed ? null : (seed ?? this.seed),
      isPinned: isPinned ?? this.isPinned,
      isArchived: isArchived ?? this.isArchived,
    );
  }
}
