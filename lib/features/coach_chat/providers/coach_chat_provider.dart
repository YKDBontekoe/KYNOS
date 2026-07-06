import 'dart:async';

import 'package:kynos/domain/entities/ai_inference_backend.dart';
import 'package:kynos/domain/entities/chat_message.dart';
import 'package:kynos/domain/entities/coach/coach_context.dart';
import 'package:kynos/domain/utils/ai_inference_error_policy.dart';
import 'package:kynos/domain/utils/coach_fallback_reply.dart';
import 'package:kynos/features/coach_chat/utils/chat_history_codec.dart';
import 'package:kynos/shared/providers/ai_repository_providers.dart';
import 'package:kynos/features/coach_chat/providers/coach_context_provider.dart';
import 'package:kynos/features/coach_chat/providers/last_coach_context_provider.dart';
import 'package:kynos/shared/providers/coach_usecase_providers.dart';
import 'package:kynos/shared/providers/shared_preferences_provider.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'coach_chat_provider.g.dart';

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
      preferredBackend: assistant.attemptedBackend,
    );
  }

  Future<void> retryWithAlternateBackend(String assistantId) async {
    _cancelRequested = false;
    final msgs = state.value;
    if (msgs == null) return;

    final assistantIndex = msgs.indexWhere((m) => m.id == assistantId);
    if (assistantIndex == -1) return;

    final assistant = msgs[assistantIndex];
    final prompt = assistant.userPromptForRetry;
    if (prompt == null || prompt.isEmpty) return;

    final alternate = _alternateBackend(assistant.attemptedBackend);
    if (alternate == null) return;

    final cleared = List<ChatMessage>.from(msgs)..[assistantIndex] = assistant.copyWith(
          content: '',
          isStreaming: true,
          hasError: false,
        );
    state = AsyncData(cleared);

    await _runInference(
      userMessage: prompt,
      existingAssistantId: assistantId,
      preferredBackend: alternate,
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
    AiInferenceBackend? preferredBackend,
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

    CoachContext? coachContext;
    try {
      final sendCoach = ref.read(sendCoachMessageUseCaseProvider);
      final chatRepository = ref.read(chatAiCoachRepositoryProvider);

      coachContext = await _loadCoachContext();
      ref.read(lastCoachContextProvider.notifier).set(coachContext);

      final priorMessages = _priorMessagesForInference(
        state.value ?? const [],
        assistantId,
      );

      await for (final chunk in sendCoach(
        userMessage: userMessage,
        coachContext: coachContext,
        conversationHistory: priorMessages,
        preferredBackend: preferredBackend,
      ).timeout(_inferenceTimeout)) {
        if (_cancelRequested) break;

        ref.read(lastAiInferenceBackendProvider.notifier).set(
              chatRepository.lastBackend,
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

      _finaliseMessage(
        assistantId,
        streaming: false,
        hasError: false,
        attemptedBackend: chatRepository.lastBackend,
      );
      await _persist();
    } catch (e, st) {
      if (_cancelRequested) return;

      _logger.e('Inference error', error: e, stackTrace: st);
      coachContext ??= await _readCoachContextSafely();
      ref.read(lastCoachContextProvider.notifier).set(coachContext);

      final attemptedBackend =
          preferredBackend ??
          ref.read(chatAiCoachRepositoryProvider).lastBackend;
      final cloudConfigured =
          await ref.read(isCloudCoachConfiguredProvider.future);
      final canSwitchToCloud = cloudConfigured &&
          attemptedBackend != AiInferenceBackend.openRouter;
      final canSwitchToOnDevice =
          attemptedBackend == AiInferenceBackend.openRouter;

      final friendly = AiInferenceErrorPolicy.userFriendlyMessage(
        e,
        canSwitchToCloud: canSwitchToCloud,
        canSwitchToOnDevice: canSwitchToOnDevice,
      );

      final showFallback = !canSwitchToCloud && !canSwitchToOnDevice;
      final fallback = showFallback
          ? CoachFallbackReply.forRecoveryQuestion(
              userMessage: userMessage,
              healthContext: coachContext.healthHistory,
            )
          : null;

      _finaliseMessage(
        assistantId,
        streaming: false,
        hasError: true,
        content: fallback == null ? friendly : '$friendly\n\n$fallback',
        userPromptForRetry: userMessage,
        attemptedBackend: attemptedBackend,
      );
      await _persist();
    }
  }

  List<ChatMessage> _priorMessagesForInference(
    List<ChatMessage> all,
    String currentAssistantId,
  ) {
    final withoutCurrent = all
        .where((m) => m.id != currentAssistantId && !m.isStreaming)
        .toList();
    return withoutCurrent;
  }

  AiInferenceBackend? _alternateBackend(AiInferenceBackend? attempted) {
    return switch (attempted) {
      AiInferenceBackend.onDevice ||
      AiInferenceBackend.rulesOnly =>
        AiInferenceBackend.openRouter,
      AiInferenceBackend.openRouter => AiInferenceBackend.onDevice,
      null => null,
    };
  }

  Future<CoachContext> _loadCoachContext() async {
    try {
      return await ref
          .read(coachContextProvider.future)
          .timeout(_healthContextTimeout);
    } on TimeoutException {
      _logger.w('Coach context timed out; using minimal context');
      return ref.read(buildCoachContextUseCaseProvider).call(
            healthHistory: const [],
            recentRuns: const [],
          );
    } on Object catch (error, stackTrace) {
      _logger.w(
        'Coach context unavailable; using minimal context',
        error: error,
        stackTrace: stackTrace,
      );
      return ref.read(buildCoachContextUseCaseProvider).call(
            healthHistory: const [],
            recentRuns: const [],
          );
    }
  }

  Future<CoachContext> _readCoachContextSafely() => _loadCoachContext();

  String _messageContent(String assistantId) {
    final msgs = state.value;
    if (msgs == null) return '';
    final idx = msgs.indexWhere((m) => m.id == assistantId);
    if (idx == -1) return '';
    return msgs[idx].content;
  }

  Future<void> clearConversation() async {
    state = const AsyncData([]);
    ref.read(lastCoachContextProvider.notifier).set(null);
    await ref.read(chatAiCoachRepositoryProvider).resetSession();
    await _persist();
  }

  void _finaliseMessage(
    String id, {
    required bool streaming,
    required bool hasError,
    String? content,
    String? userPromptForRetry,
    AiInferenceBackend? attemptedBackend,
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
      attemptedBackend: attemptedBackend ?? msgs[idx].attemptedBackend,
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
