import 'dart:convert';

import 'package:kynos/domain/entities/chat_message.dart';

/// Serialises coach chat history to SharedPreferences JSON.
abstract final class ChatHistoryCodec {
  static const prefsKey = 'coach_chat_history_v1';

  static List<ChatMessage> decode(String? raw) {
    if (raw == null || raw.isEmpty) return const [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((item) => _fromMap(item as Map<String, dynamic>))
          .where((m) => m.content.isNotEmpty && !m.isStreaming)
          .toList();
    } on Object {
      return const [];
    }
  }

  static String encode(List<ChatMessage> messages) {
    final persisted = messages
        .where((m) => m.content.isNotEmpty && !m.isStreaming)
        .map(_toMap)
        .toList();
    return jsonEncode(persisted);
  }

  static Map<String, dynamic> _toMap(ChatMessage message) {
    return {
      'id': message.id,
      'role': message.role.name,
      'content': message.content,
      'timestamp': message.timestamp.toIso8601String(),
      'hasError': message.hasError,
      'userPromptForRetry': message.userPromptForRetry,
    };
  }

  static ChatMessage _fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'] as String,
      role: MessageRole.values.byName(map['role'] as String),
      content: map['content'] as String,
      timestamp: DateTime.parse(map['timestamp'] as String),
      hasError: map['hasError'] as bool? ?? false,
      userPromptForRetry: map['userPromptForRetry'] as String?,
    );
  }
}
