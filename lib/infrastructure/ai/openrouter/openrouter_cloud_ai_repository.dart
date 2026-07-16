import 'package:kynos/domain/entities/chat_message.dart';
import 'package:kynos/domain/repositories/cloud_ai_repository.dart';
import 'package:kynos/infrastructure/ai/openai_compatible/openai_compatible_cloud_ai_repository.dart';

/// @Deprecated — use [OpenAiCompatibleCloudAiRepository].
class OpenRouterCloudAiRepository implements CloudAiRepository {
  OpenRouterCloudAiRepository({OpenAiCompatibleCloudAiRepository? delegate})
      : _delegate = delegate ?? OpenAiCompatibleCloudAiRepository();

  final OpenAiCompatibleCloudAiRepository _delegate;

  @override
  Stream<String> streamCompletion({
    required String apiKey,
    required String modelId,
    required String systemPrompt,
    required String userPrompt,
    String? baseUrl,
  }) {
    return _delegate.streamCompletion(
      apiKey: apiKey,
      modelId: modelId,
      systemPrompt: systemPrompt,
      userPrompt: userPrompt,
      baseUrl: baseUrl,
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
    return _delegate.streamChat(
      apiKey: apiKey,
      modelId: modelId,
      systemPrompt: systemPrompt,
      conversationHistory: conversationHistory,
      userMessage: userMessage,
      baseUrl: baseUrl,
    );
  }
}
