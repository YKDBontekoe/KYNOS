import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:kynos/domain/entities/openrouter_model.dart';
import 'package:kynos/domain/entities/openrouter_model_filters.dart';
import 'package:kynos/domain/utils/cloud_prompt_sanitizer.dart';

/// Thin REST client for OpenRouter — models catalog and streaming chat.
class OpenRouterApiClient {
  OpenRouterApiClient({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: 'https://openrouter.ai/api/v1',
                connectTimeout: const Duration(seconds: 15),
                receiveTimeout: const Duration(seconds: 60),
                headers: const {
                  'HTTP-Referer': 'https://kynos.app',
                  'X-Title': 'KYNOS',
                },
              ),
            );

  final Dio _dio;

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
  }) async* {
    final sanitizedSystem = CloudPromptSanitizer.sanitize(systemPrompt);
    final sanitizedUser = CloudPromptSanitizer.sanitize(userPrompt);

    final response = await _dio.post<ResponseBody>(
      '/chat/completions',
      data: {
        'model': modelId,
        'stream': true,
        'messages': [
          {'role': 'system', 'content': sanitizedSystem},
          {'role': 'user', 'content': sanitizedUser},
        ],
      },
      options: Options(
        headers: {'Authorization': 'Bearer $apiKey'},
        responseType: ResponseType.stream,
      ),
    );

    final stream = response.data?.stream;
    if (stream == null) return;

    var buffer = '';
    await for (final chunk in stream) {
      buffer += utf8.decode(chunk);
      while (buffer.contains('\n')) {
        final index = buffer.indexOf('\n');
        final line = buffer.substring(0, index).trim();
        buffer = buffer.substring(index + 1);

        if (!line.startsWith('data:')) continue;
        final payload = line.substring(5).trim();
        if (payload == '[DONE]') return;

        try {
          final json = jsonDecode(payload) as Map<String, dynamic>;
          final choices = json['choices'] as List<dynamic>?;
          if (choices == null || choices.isEmpty) continue;
          final first = choices.first;
          if (first is! Map<String, dynamic>) continue;
          final delta = first['delta'];
          if (delta is! Map<String, dynamic>) continue;
          final content = delta['content'];
          if (content is String && content.isNotEmpty) {
            yield content;
          }
        } on Object {
          continue;
        }
      }
    }
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
