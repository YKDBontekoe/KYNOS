import 'package:kynos/domain/entities/chat_message.dart';

/// Cloud inference backend for BYOK OpenAI-compatible endpoints.
abstract interface class CloudAiRepository {
  /// Streams completion tokens from the user's selected cloud model.
  Stream<String> streamCompletion({
    required String apiKey,
    required String modelId,
    required String systemPrompt,
    required String userPrompt,
    String? baseUrl,
  });

  /// Multi-turn chat with prior [conversationHistory] plus the latest user turn.
  Stream<String> streamChat({
    required String apiKey,
    required String modelId,
    required String systemPrompt,
    required List<ChatMessage> conversationHistory,
    required String userMessage,
    String? baseUrl,
  });
}
