import 'package:dio/dio.dart';
import 'package:kynos/domain/entities/cloud_llm_endpoint.dart';
import 'package:kynos/domain/entities/openrouter_model.dart';
import 'package:kynos/domain/entities/openrouter_model_filters.dart';
import 'package:kynos/infrastructure/ai/openai_compatible/openai_compatible_api_client.dart';

/// OpenRouter models catalog + streaming chat (OpenAI-compatible).
class OpenRouterApiClient {
  OpenRouterApiClient({Dio? dio, OpenAiCompatibleApiClient? chatClient})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: CloudLlmEndpoint.openRouterBaseUrl,
                connectTimeout: const Duration(seconds: 15),
                receiveTimeout: const Duration(seconds: 60),
                headers: const {
                  'HTTP-Referer': 'https://kynos.app',
                  'X-Title': 'KYNOS',
                },
              ),
            ),
        _chatClient = chatClient ??
            OpenAiCompatibleApiClient(baseUrl: CloudLlmEndpoint.openRouterBaseUrl);

  final Dio _dio;
  final OpenAiCompatibleApiClient _chatClient;

  Future<({List<OpenRouterModel>? models, String? error})> listModels({
    required String apiKey,
    required OpenRouterModelFilters filters,
  }) async {
    try {
      final query = <String, dynamic>{
        'sort': filters.sort.apiValue,
        'output_modalities': 'text',
        if (filters.query != null && filters.query!.isNotEmpty) 'q': filters.query,
        if (filters.minContextTokens != null) 'context': filters.minContextTokens,
        if (filters.architecture != null) 'arch': filters.architecture,
        if (filters.modelAuthors != null) 'model_authors': filters.modelAuthors,
        if (filters.providers != null) 'providers': filters.providers,
      };

      if (filters.freeOnly) {
        query['max_price'] = 0;
      } else {
        if (filters.minPricePerM != null) {
          query['min_price'] = filters.minPricePerM;
        }
        if (filters.maxPricePerM != null) {
          query['max_price'] = filters.maxPricePerM;
        }
      }

      final response = await _dio.get<Map<String, dynamic>>(
        '/models',
        queryParameters: query,
        options: Options(
          headers: {'Authorization': 'Bearer $apiKey'},
        ),
      );

      final data = response.data?['data'];
      if (data is! List) {
        return (models: null, error: 'Unexpected models response');
      }

      var models = data
          .whereType<Map<String, dynamic>>()
          .map(_parseModel)
          .where((m) => m.id.isNotEmpty)
          .toList();

      if (filters.freeOnly) {
        models = models.where(isFreeOpenRouterModel).toList();
      }

      return (models: models, error: null);
    } on DioException catch (e) {
      return (models: null, error: e.message ?? e.toString());
    } on Object catch (e) {
      return (models: null, error: e.toString());
    }
  }

  Stream<String> streamChatCompletion({
    required String apiKey,
    required String modelId,
    required String systemPrompt,
    required String userPrompt,
  }) {
    return _chatClient.streamChatCompletion(
      apiKey: apiKey,
      modelId: modelId,
      systemPrompt: systemPrompt,
      userPrompt: userPrompt,
    );
  }

  Stream<String> streamChatMessages({
    required String apiKey,
    required String modelId,
    required String systemPrompt,
    required List<Map<String, String>> messages,
  }) {
    return _chatClient.streamChatMessages(
      apiKey: apiKey,
      modelId: modelId,
      systemPrompt: systemPrompt,
      messages: messages,
    );
  }

  OpenRouterModel _parseModel(Map<String, dynamic> json) {
    final pricingJson = json['pricing'];
    final pricing = pricingJson is Map<String, dynamic>
        ? OpenRouterModelPricing(
            prompt: pricingJson['prompt']?.toString() ?? '0',
            completion: pricingJson['completion']?.toString() ?? '0',
          )
        : const OpenRouterModelPricing(prompt: '0', completion: '0');

    return OpenRouterModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      contextLength: (json['context_length'] as num?)?.toInt() ?? 0,
      pricing: pricing,
      description: json['description']?.toString(),
      expirationDate: json['expiration_date']?.toString(),
    );
  }
}
