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
}
