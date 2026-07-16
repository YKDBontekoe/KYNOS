import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:kynos/domain/entities/cloud_llm_endpoint.dart';
import 'package:kynos/domain/utils/cloud_prompt_sanitizer.dart';

/// Thin REST client for any OpenAI-compatible `/v1/chat/completions` endpoint.
class OpenAiCompatibleApiClient {
  OpenAiCompatibleApiClient({
    String baseUrl = CloudLlmEndpoint.openRouterBaseUrl,
    Dio? dio,
  }) : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: CloudLlmEndpoint.normalizeBaseUrl(baseUrl),
                connectTimeout: const Duration(seconds: 15),
                receiveTimeout: const Duration(seconds: 60),
                headers: const {
                  'HTTP-Referer': 'https://kynos.app',
                  'X-Title': 'KYNOS',
                },
              ),
            );

  final Dio _dio;

  /// Returns a client pointed at [baseUrl] (reuses this instance when equal).
  OpenAiCompatibleApiClient withBaseUrl(String baseUrl) {
    final normalized = CloudLlmEndpoint.normalizeBaseUrl(baseUrl);
    if (_dio.options.baseUrl == normalized) return this;
    return OpenAiCompatibleApiClient(baseUrl: normalized);
  }

  Stream<String> streamChatCompletion({
    required String apiKey,
    required String modelId,
    required String systemPrompt,
    required String userPrompt,
  }) async* {
    yield* _streamMessages(
      apiKey: apiKey,
      modelId: modelId,
      messages: [
        {
          'role': 'system',
          'content': CloudPromptSanitizer.sanitize(systemPrompt),
        },
        {
          'role': 'user',
          'content': CloudPromptSanitizer.sanitize(userPrompt),
        },
      ],
    );
  }

  Stream<String> streamChatMessages({
    required String apiKey,
    required String modelId,
    required String systemPrompt,
    required List<Map<String, String>> messages,
  }) async* {
    final sanitized = [
      {
        'role': 'system',
        'content': CloudPromptSanitizer.sanitize(systemPrompt),
      },
      ...messages.map(
        (m) => {
          'role': m['role']!,
          'content': CloudPromptSanitizer.sanitize(m['content']!),
        },
      ),
    ];
    yield* _streamMessages(
      apiKey: apiKey,
      modelId: modelId,
      messages: sanitized,
    );
  }

  Stream<String> _streamMessages({
    required String apiKey,
    required String modelId,
    required List<Map<String, String>> messages,
  }) async* {
    final response = await _dio.post<ResponseBody>(
      '/chat/completions',
      data: {
        'model': modelId,
        'stream': true,
        'messages': messages,
      },
      options: Options(
        headers: {'Authorization': 'Bearer $apiKey'},
        responseType: ResponseType.stream,
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    if (response.statusCode != null && response.statusCode! >= 400) {
      final errorBuffer = StringBuffer();
      final errorStream = response.data?.stream;
      if (errorStream != null) {
        await for (final chunk in errorStream) {
          errorBuffer.write(utf8.decode(chunk));
        }
      }
      final errorBody = errorBuffer.toString();
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: errorBody.isNotEmpty
            ? errorBody
            : 'Cloud LLM request failed (${response.statusCode})',
      );
    }

    final stream = response.data?.stream;
    if (stream == null) {
      throw StateError('Cloud LLM returned an empty stream');
    }

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
}
