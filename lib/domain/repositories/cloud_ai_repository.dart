/// Cloud inference backend for BYOK OpenRouter requests.
abstract interface class CloudAiRepository {
  /// Streams completion tokens from the user's selected OpenRouter model.
  Stream<String> streamCompletion({
    required String apiKey,
    required String modelId,
    required String systemPrompt,
    required String userPrompt,
  });
}
