import 'package:kynos/domain/entities/chat_message.dart';
import 'package:kynos/domain/entities/cloud_llm_endpoint.dart';
import 'package:kynos/domain/repositories/cloud_ai_repository.dart';
import 'package:kynos/infrastructure/ai/openai_compatible/openai_compatible_api_client.dart';

/// BYOK cloud coach backed by any OpenAI-compatible chat completions API.
class OpenAiCompatibleCloudAiRepository implements CloudAiRepository {
  OpenAiCompatibleCloudAiRepository({OpenAiCompatibleApiClient? client})
      : _client = client ?? OpenAiCompatibleApiClient();

  final OpenAiCompatibleApiClient _client;

  OpenAiCompatibleApiClient _clientFor(String? baseUrl) {
    final url = (baseUrl == null || baseUrl.isEmpty)
        ? CloudLlmEndpoint.openRouterBaseUrl
        : baseUrl;
    return _client.withBaseUrl(url);
  }

  @override
  Stream<String> streamCompletion({
    required String apiKey,
    required String modelId,
    required String systemPrompt,
    required String userPrompt,
    String? baseUrl,
  }) {
    return _clientFor(baseUrl).streamChatCompletion(
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
    String? baseUrl,
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

    return _clientFor(baseUrl).streamChatMessages(
      apiKey: apiKey,
      modelId: modelId,
      systemPrompt: systemPrompt,
      messages: messages,
    );
  }
}
