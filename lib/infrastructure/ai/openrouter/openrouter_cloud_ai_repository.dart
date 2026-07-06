import 'package:kynos/domain/entities/chat_message.dart';
import 'package:kynos/domain/repositories/cloud_ai_repository.dart';
import 'package:kynos/infrastructure/ai/openrouter/openrouter_api_client.dart';

class OpenRouterCloudAiRepository implements CloudAiRepository {
  OpenRouterCloudAiRepository({OpenRouterApiClient? client})
      : _client = client ?? OpenRouterApiClient();

  final OpenRouterApiClient _client;

  @override
  Stream<String> streamCompletion({
    required String apiKey,
    required String modelId,
    required String systemPrompt,
    required String userPrompt,
  }) {
    return _client.streamChatCompletion(
      apiKey: apiKey,
      modelId: modelId,
      systemPrompt: systemPrompt,
      userPrompt: userPrompt,
    );
  }

  @override
  Stream<String> streamChat({
    required String apiKey,
    required String modelId,
    required String systemPrompt,
    required List<ChatMessage> conversationHistory,
    required String userMessage,
  }) {
    final messages = conversationHistory
        .where((m) => m.content.trim().isNotEmpty && !m.isStreaming)
        .map(
          (m) => {
            'role': m.role == MessageRole.user ? 'user' : 'assistant',
            'content': m.content.trim(),
          },
        )
        .toList();

    messages.add({'role': 'user', 'content': userMessage});

    return _client.streamChatMessages(
      apiKey: apiKey,
      modelId: modelId,
      systemPrompt: systemPrompt,
      messages: messages,
    );
  }
}
