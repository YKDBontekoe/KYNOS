import 'dart:async';

import 'package:kynos/domain/entities/ai_inference_backend.dart';
import 'package:kynos/domain/entities/chat_message.dart';
import 'package:kynos/domain/entities/coach/coach_context.dart';
import 'package:kynos/domain/entities/coach/coach_conversation.dart';
import 'package:kynos/domain/entities/coach/coach_conversation_settings.dart';
import 'package:kynos/domain/utils/ai_inference_error_policy.dart';
import 'package:kynos/domain/utils/coach_fallback_reply.dart';
import 'package:kynos/features/coach_chat/providers/active_coach_conversation_provider.dart';
import 'package:kynos/features/coach_chat/providers/coach_conversations_provider.dart';
import 'package:kynos/features/coach_chat/providers/last_coach_context_provider.dart';
import 'package:kynos/shared/providers/ai_repository_providers.dart';
import 'package:kynos/shared/providers/coach_context_provider.dart';
import 'package:kynos/shared/providers/coach_conversation_providers.dart';
import 'package:kynos/shared/providers/coach_usecase_providers.dart';
import 'package:kynos/shared/providers/settings_provider.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'coach_chat_provider.g.dart';

const _healthContextTimeout = Duration(seconds: 8);
const _inferenceTimeout = Duration(seconds: 120);

@Riverpod(keepAlive: true)
class CoachChat extends _$CoachChat {
  final _logger = Logger();
  bool _cancelRequested = false;
  Future<void> _persistChain = Future.value();

  @override
  Future<List<ChatMessage>> build() async {
    final conversationId = ref.watch(activeCoachConversationIdProvider);
    if (conversationId == null) return const [];
    final result =
        await ref.read(getCoachConversationUseCaseProvider).call(conversationId);
    return result.conversation?.messages ?? const [];
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

    final cleared = List<ChatMessage>.from(msgs)
      ..[assistantIndex] = assistant.copyWith(
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

    final cleared = List<ChatMessage>.from(msgs)
      ..[assistantIndex] = assistant.copyWith(
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

  Future<void> updateSettings(CoachConversationSettings settings) async {
    final conversation = await _loadConversation();
    if (conversation == null) return;
    await _saveConversation(
      conversation.copyWith(settings: settings, updatedAt: DateTime.now()),
    );
    ref.invalidate(activeCoachConversationProvider);
  }

  Future<void> clearMessages() async {
    state = const AsyncData([]);
    ref.read(lastCoachContextProvider.notifier).set(null);
    await ref.read(chatAiCoachRepositoryProvider).resetSession();
    final conversation = await _loadConversation();
    if (conversation != null) {
      await _saveConversation(
        conversation.copyWith(
          messages: const [],
          updatedAt: DateTime.now(),
        ),
      );
    }
  }

  Future<void> _runInference({
    required String userMessage,
    String? existingAssistantId,
    AiInferenceBackend? preferredBackend,
  }) async {
    final current = state.value ?? const [];
    final settings = await _conversationSettings();
    final contextSnapshotIds = settings.contextPreferences.enabledSources
        .map((source) => source.name)
        .toList();

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
        contextSnapshotIds: contextSnapshotIds,
      );
      state = AsyncData([...current, userMsg, placeholder]);
      await _maybeAutoTitle(userMessage, current.isEmpty);
    }

    CoachContext? coachContext;
    try {
      final sendCoach = ref.read(sendCoachMessageUseCaseProvider);
      final chatRepository = ref.read(chatAiCoachRepositoryProvider);

      coachContext = await _loadCoachContext(settings);
      ref.read(lastCoachContextProvider.notifier).set(coachContext);

      final priorMessages = _priorMessagesForInference(
        state.value ?? const [],
        assistantId,
      );

      final globalSettings = ref.read(settingsProvider);
      final cloudLevel = ref.read(filterCoachContextUseCaseProvider).effectiveCloudLevel(
            globalLevel: globalSettings.cloudDataLevel,
            preferences: settings.contextPreferences,
          );

      await for (final chunk in sendCoach(
        userMessage: userMessage,
        coachContext: coachContext,
        conversationHistory: priorMessages,
        preferredBackend: preferredBackend,
        backendMode: settings.backendMode,
        cloudModelIdOverride: settings.preferredCloudModelId,
        cloudDataLevelOverride: cloudLevel,
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
        contextSnapshotIds: contextSnapshotIds,
      );
      await _persist();
    } catch (e, st) {
      if (_cancelRequested) return;

      _logger.e('Inference error', error: e, stackTrace: st);
      coachContext ??= await _readCoachContextSafely(settings);
      ref.read(lastCoachContextProvider.notifier).set(coachContext);

      final attemptedBackend =
          preferredBackend ?? ref.read(chatAiCoachRepositoryProvider).lastBackend;
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
        contextSnapshotIds: contextSnapshotIds,
      );
      await _persist();
    }
  }

  Future<void> _maybeAutoTitle(String userMessage, bool isFirstMessage) async {
    if (!isFirstMessage) return;
    final conversation = await _loadConversation();
    if (conversation == null || conversation.title != 'New chat') return;
    final title = ref
        .read(updateCoachConversationUseCaseProvider)
        .titleFromFirstMessage(userMessage);
    await _saveConversation(
      conversation.copyWith(title: title, updatedAt: DateTime.now()),
    );
    await ref.read(coachConversationsProvider.notifier).refresh();
  }

  List<ChatMessage> _priorMessagesForInference(
    List<ChatMessage> all,
    String currentAssistantId,
  ) {
    return all
        .where((m) => m.id != currentAssistantId && !m.isStreaming)
        .toList();
  }

  AiInferenceBackend? _alternateBackend(AiInferenceBackend? attempted) {
    return switch (attempted) {
      AiInferenceBackend.onDevice || AiInferenceBackend.rulesOnly =>
        AiInferenceBackend.openRouter,
      AiInferenceBackend.openRouter => AiInferenceBackend.onDevice,
      null => null,
    };
  }

  Future<CoachContext> _loadCoachContext(CoachConversationSettings settings) async {
    try {
      final conversation = await _loadConversation();
      final fullContext = await ref
          .read(
            coachContextForConversationProvider(
              seed: conversation?.seed,
            ).future,
          )
          .timeout(_healthContextTimeout);
      return ref.read(filterCoachContextUseCaseProvider).call(
            context: fullContext,
            preferences: settings.contextPreferences,
          );
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

  Future<CoachContext> _readCoachContextSafely(
    CoachConversationSettings settings,
  ) =>
      _loadCoachContext(settings);

  String _messageContent(String assistantId) {
    final msgs = state.value;
    if (msgs == null) return '';
    final idx = msgs.indexWhere((m) => m.id == assistantId);
    if (idx == -1) return '';
    return msgs[idx].content;
  }

  void _finaliseMessage(
    String id, {
    required bool streaming,
    required bool hasError,
    String? content,
    String? userPromptForRetry,
    AiInferenceBackend? attemptedBackend,
    List<String>? contextSnapshotIds,
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
      contextSnapshotIds: contextSnapshotIds ?? msgs[idx].contextSnapshotIds,
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
    final conversation = await _loadConversation();
    if (conversation == null) return;
    await _saveConversation(
      conversation.copyWith(
        messages: messages,
        updatedAt: DateTime.now(),
      ),
    );
    await ref.read(coachConversationsProvider.notifier).refresh();
    ref.invalidate(activeCoachConversationProvider);
  }

  Future<CoachConversation?> _loadConversation() async {
    final conversationId = ref.read(activeCoachConversationIdProvider);
    if (conversationId == null) return null;
    final result =
        await ref.read(getCoachConversationUseCaseProvider).call(conversationId);
    return result.conversation;
  }

  Future<CoachConversationSettings> _conversationSettings() async {
    final conversation = await _loadConversation();
    return conversation?.settings ?? CoachConversationSettings.defaults;
  }

  Future<void> _saveConversation(CoachConversation conversation) async {
    await ref.read(updateCoachConversationUseCaseProvider).call(conversation);
  }
}

@Riverpod(keepAlive: true)
class LastAiInferenceBackend extends _$LastAiInferenceBackend {
  @override
  AiInferenceBackend build() => AiInferenceBackend.onDevice;

  void set(AiInferenceBackend backend) => state = backend;
}
