import 'dart:async';

import 'package:kynos/domain/entities/ai_inference_backend.dart';
import 'package:kynos/domain/entities/chat_message.dart';
import 'package:kynos/domain/entities/health_summary.dart';
import 'package:kynos/domain/utils/ai_inference_error_policy.dart';
import 'package:kynos/domain/utils/coach_fallback_reply.dart';
import 'package:kynos/features/coach_chat/utils/chat_history_codec.dart';
import 'package:kynos/shared/providers/ai_repository_providers.dart';
import 'package:kynos/shared/providers/health_providers.dart';
import 'package:kynos/shared/providers/shared_preferences_provider.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'coach_chat_provider.g.dart';

const _coachHealthHistoryDays = 14;
const _healthContextTimeout = Duration(seconds: 8);
const _inferenceTimeout = Duration(seconds: 120);

@Riverpod(keepAlive: true)
class CoachChatNotifier extends _$CoachChatNotifier {
  final _logger = Logger();
  bool _cancelRequested = false;
  Future<void> _persistChain = Future.value();

  @override
  Future<List<ChatMessage>> build() async {
    final prefs = ref.read(sharedPreferencesProvider);
    return ChatHistoryCodec.decode(prefs.getString(ChatHistoryCodec.prefsKey));
  }

  Future<void> sendMessage(String userMessage) async {
    _cancelRequested = false;
    await _runInference(userMessage: userMessage);
  }

  Future<void> retryMessage(String assistantId) async {
    _cancelRequested = false;
    final msgs = state.value;
    if (msgs == null) return;

    final assistantIndex = msgs.indexWhere((m) => m.id == assistantId);
    if (assistantIndex == -1) return;

    final assistant = msgs[assistantIndex];
    final prompt = assistant.userPromptForRetry;
    if (prompt == null || prompt.isEmpty) return;

    final cleared = List<ChatMessage>.from(msgs)..[assistantIndex] = assistant.copyWith(
          content: '',
          isStreaming: true,
          hasError: false,
        );
    state = AsyncData(cleared);

    await _runInference(
      userMessage: prompt,
      existingAssistantId: assistantId,
    );
  }

  void cancelGeneration() {
    _cancelRequested = true;
    final msgs = state.value;
    if (msgs == null) return;

    final streamingIndex = msgs.indexWhere((m) => m.isStreaming);
    if (streamingIndex == -1) return;

    final streaming = msgs[streamingIndex];
    final updated = streaming.copyWith(
      isStreaming: false,
      content: streaming.content.isEmpty
          ? 'Generation stopped.'
          : '${streaming.content}\n\n_(stopped)_',
    );
    state = AsyncData(List<ChatMessage>.from(msgs)..[streamingIndex] = updated);
    unawaited(_persist());
  }

  Future<void> _runInference({
    required String userMessage,
    String? existingAssistantId,
  }) async {
    final current = state.value ?? const [];

    late final String assistantId;

    if (existingAssistantId != null) {
      assistantId = existingAssistantId;
    } else {
      final userMsg = ChatMessage(
        id: '${DateTime.now().microsecondsSinceEpoch}_user',
        role: MessageRole.user,
        content: userMessage,
        timestamp: DateTime.now(),
      );
      assistantId = '${DateTime.now().microsecondsSinceEpoch}_assistant';
      final placeholder = ChatMessage(
        id: assistantId,
        role: MessageRole.assistant,
        content: '',
        timestamp: DateTime.now(),
        isStreaming: true,
        userPromptForRetry: userMessage,
      );
      state = AsyncData([...current, userMsg, placeholder]);
    }

    List<HealthSummary>? healthContext;
    try {
      final repository = ref.read(aiCoachRepositoryProvider);
      healthContext = await _loadHealthContext();

      final estimatedTokens = _estimateTokens(userMessage, healthContext);

      await for (final chunk in repository.chat(
        userMessage: userMessage,
        healthContext: healthContext,
        estimatedPromptTokens: estimatedTokens,
      ).timeout(_inferenceTimeout)) {
        if (_cancelRequested) break;

        ref.read(lastAiInferenceBackendProvider.notifier).set(
              repository.lastBackend,
            );

        final msgs = state.value!;
        final idx = msgs.indexWhere((m) => m.id == assistantId);
        if (idx == -1) break;

        final updated = msgs[idx].copyWith(
          content: msgs[idx].content + chunk,
        );
        state = AsyncData(List<ChatMessage>.from(msgs)..[idx] = updated);
      }

      if (_cancelRequested) return;

      final finalContent = _messageContent(assistantId);
      if (finalContent.trim().isEmpty) {
        throw StateError('Coach returned an empty response');
      }

      _finaliseMessage(assistantId, streaming: false, hasError: false);
      await _persist();
    } catch (e, st) {
      if (_cancelRequested) return;

      _logger.e('Inference error', error: e, stackTrace: st);
      healthContext ??= await _readHealthContextSafely();

      final friendly = AiInferenceErrorPolicy.userFriendlyMessage(e);
      final fallback = CoachFallbackReply.forRecoveryQuestion(
        userMessage: userMessage,
        healthContext: healthContext,
      );

      _finaliseMessage(
        assistantId,
        streaming: false,
        hasError: true,
        content: '$friendly\n\n$fallback',
        userPromptForRetry: userMessage,
      );
      await _persist();
    }
  }

  int _estimateTokens(String message, List<HealthSummary> healthContext) {
    final chars = message.length + healthContext.length * 80;
    return (chars / 4).round();
  }

  Future<List<HealthSummary>> _loadHealthContext() async {
    try {
      return await ref
          .read(healthHistoryProvider(days: _coachHealthHistoryDays).future)
          .timeout(_healthContextTimeout);
    } on TimeoutException {
      _logger.w('Health context timed out; proceeding without history');
      return const [];
    } on Object catch (error, stackTrace) {
      _logger.w(
        'Health context unavailable; proceeding without history',
        error: error,
        stackTrace: stackTrace,
      );
      return const [];
    }
  }

  String _messageContent(String assistantId) {
    final msgs = state.value;
    if (msgs == null) return '';
    final idx = msgs.indexWhere((m) => m.id == assistantId);
    if (idx == -1) return '';
    return msgs[idx].content;
  }

  Future<List<HealthSummary>> _readHealthContextSafely() => _loadHealthContext();

  Future<void> clearConversation() async {
    state = const AsyncData([]);
    await ref.read(aiCoachRepositoryProvider).resetSession();
    await _persist();
  }

  void _finaliseMessage(
    String id, {
    required bool streaming,
    required bool hasError,
    String? content,
    String? userPromptForRetry,
  }) {
    final msgs = state.value;
    if (msgs == null) return;

    final idx = msgs.indexWhere((m) => m.id == id);
    if (idx == -1) return;

    final updated = msgs[idx].copyWith(
      isStreaming: streaming,
      hasError: hasError,
      content: content ?? msgs[idx].content,
      userPromptForRetry: userPromptForRetry ?? msgs[idx].userPromptForRetry,
    );
    state = AsyncData(List<ChatMessage>.from(msgs)..[idx] = updated);
  }

  Future<void> _persist() {
    _persistChain = _persistChain.then((_) => _persistNow());
    return _persistChain;
  }

  Future<void> _persistNow() async {
    final messages = state.value;
    if (messages == null) return;
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(
      ChatHistoryCodec.prefsKey,
      ChatHistoryCodec.encode(messages),
    );
  }
}

@Riverpod(keepAlive: true)
class LastAiInferenceBackend extends _$LastAiInferenceBackend {
  @override
  AiInferenceBackend build() => AiInferenceBackend.onDevice;

  void set(AiInferenceBackend backend) => state = backend;
}
