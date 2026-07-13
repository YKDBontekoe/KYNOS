import 'dart:async';
import 'dart:convert';

import 'package:kynos/domain/entities/ai_inference_backend.dart';
import 'package:kynos/domain/entities/chat_message.dart';
import 'package:kynos/domain/entities/cloud_data_level.dart';
import 'package:kynos/domain/entities/coach/coach_context.dart';
import 'package:kynos/domain/entities/coach/coach_conversation.dart';
import 'package:kynos/domain/entities/coach/coach_conversation_settings.dart';
import 'package:kynos/domain/entities/coach/coach_tool_call.dart';
import 'package:kynos/domain/entities/coach/coach_tool_definition.dart';
import 'package:kynos/domain/entities/health/health_coach_models.dart';
import 'package:kynos/domain/entities/health/health_visual_artifact.dart';
import 'package:kynos/domain/utils/ai_inference_error_policy.dart';
import 'package:kynos/domain/utils/coach_fallback_reply.dart';
import 'package:kynos/domain/utils/coach_tool_call_parser.dart';
import 'package:kynos/domain/utils/health_safety_policy.dart';
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

/// Maximum agentic tool calls per assistant turn — bounds latency and keeps
/// on-device token budgets in check (see [GemmaInferenceLimits]).
const _maxToolStepsPerTurn = 4;
const _toolTimeout = Duration(seconds: 12);

@Riverpod(keepAlive: true)
class CoachChat extends _$CoachChat {
  final _logger = Logger();
  bool _cancelRequested = false;
  Future<void> _persistChain = Future.value();

  @override
  Future<List<ChatMessage>> build() async {
    final conversationId = ref.watch(activeCoachConversationIdProvider);
    if (conversationId == null) return const [];
    final result = await ref
        .read(getCoachConversationUseCaseProvider)
        .call(conversationId);
    return result.conversation?.messages ?? const [];
  }

  Future<void> sendMessage(String userMessage) async {
    _cancelRequested = false;
    if (HealthSafetyPolicy.hasUrgentText(userMessage)) {
      await _respondToUrgentSymptom(userMessage);
      return;
    }
    await _runInference(userMessage: userMessage);
  }

  Future<void> _respondToUrgentSymptom(String userMessage) async {
    final current = state.value ?? const [];
    final timestamp = DateTime.now();
    final user = ChatMessage(
      id: '${timestamp.microsecondsSinceEpoch}_user',
      role: MessageRole.user,
      content: userMessage,
      timestamp: timestamp,
    );
    final response = ChatMessage(
      id: '${timestamp.microsecondsSinceEpoch}_assistant',
      role: MessageRole.assistant,
      content: HealthSafetyPolicy.urgentGuidance,
      timestamp: timestamp,
      attemptedBackend: AiInferenceBackend.rulesOnly,
      userPromptForRetry: userMessage,
    );
    state = AsyncData([...current, user, response]);
    await _maybeAutoTitle(userMessage, current.isEmpty);
    await _persist();
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
        clearToolSteps: true,
        clearStructuredContent: true,
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
        clearToolSteps: true,
        clearStructuredContent: true,
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
        conversation.copyWith(messages: const [], updatedAt: DateTime.now()),
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
      final chatRepository = ref.read(chatAiCoachRepositoryProvider);

      coachContext = await _loadCoachContext(settings);
      ref.read(lastCoachContextProvider.notifier).set(coachContext);

      final priorMessages = _priorMessagesForInference(
        state.value ?? const [],
        assistantId,
      );

      final globalSettings = ref.read(settingsProvider);
      final cloudLevel = ref
          .read(filterCoachContextUseCaseProvider)
          .effectiveCloudLevel(
            globalLevel: globalSettings.cloudDataLevel,
            preferences: settings.contextPreferences,
          );

      await _streamAgenticAnswer(
        assistantId: assistantId,
        userMessage: userMessage,
        coachContext: coachContext,
        settings: settings,
        priorMessages: priorMessages,
        preferredBackend: preferredBackend,
        cloudLevel: cloudLevel,
      );

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
          preferredBackend ??
          ref.read(chatAiCoachRepositoryProvider).lastBackend;
      final cloudConfigured = await ref.read(
        isCloudCoachConfiguredProvider.future,
      );
      final canSwitchToCloud =
          cloudConfigured && attemptedBackend != AiInferenceBackend.openRouter;
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

  /// Streams one assistant turn, transparently resolving agentic tool calls.
  ///
  /// The model may reply with a `TOOL_CALL` directive instead of an answer
  /// (see [CoachAgentToolCatalog]). When it does, this executes the tool via
  /// [ExecuteCoachToolUseCase] and re-prompts with the result — up to
  /// [_maxToolStepsPerTurn] times — before falling back to a direct answer.
  /// Non-tool-call output still streams live to the UI token-by-token.
  Future<void> _streamAgenticAnswer({
    required String assistantId,
    required String userMessage,
    required CoachContext coachContext,
    required CoachConversationSettings settings,
    required List<ChatMessage> priorMessages,
    required AiInferenceBackend? preferredBackend,
    required CloudDataLevel cloudLevel,
  }) async {
    final sendCoach = ref.read(sendCoachMessageUseCaseProvider);
    final executeTool = ref.read(executeCoachToolUseCaseProvider);
    final chatRepository = ref.read(chatAiCoachRepositoryProvider);

    var nextUserMessage = userMessage;
    CoachContext? contextForThisCall = coachContext;
    final toolSteps = <CoachToolStep>[];
    final toolResults = <CoachToolResult>[];
    final visualArtifacts = <HealthVisualArtifact>[];
    final findings = <HealthFinding>[];
    final pendingActions = <PendingCoachAction>[];
    final executedCalls = <String>{};

    for (var step = 0; step <= _maxToolStepsPerTurn; step++) {
      if (_cancelRequested) return;

      final buffer = StringBuffer();
      var toolCallRuledOut = false;
      var flushedLiveStart = false;

      await for (final chunk in sendCoach(
        userMessage: nextUserMessage,
        coachContext: contextForThisCall,
        conversationHistory: priorMessages,
        preferredBackend: preferredBackend,
        backendMode: settings.backendMode,
        cloudModelIdOverride: settings.preferredCloudModelId,
        cloudDataLevelOverride: cloudLevel,
      ).timeout(_inferenceTimeout)) {
        if (_cancelRequested) break;
        buffer.write(chunk);

        ref
            .read(lastAiInferenceBackendProvider.notifier)
            .set(chatRepository.lastBackend);

        if (!toolCallRuledOut &&
            CoachToolCallParser.isDefinitelyNotToolCall(buffer.toString())) {
          toolCallRuledOut = true;
        }
        if (toolCallRuledOut) {
          final toAppend = flushedLiveStart ? chunk : buffer.toString();
          flushedLiveStart = true;
          _appendAssistantContent(assistantId, toAppend);
        }
      }

      if (_cancelRequested) return;

      final fullText = buffer.toString();
      final isLastAllowedStep = step == _maxToolStepsPerTurn;
      final toolCall = isLastAllowedStep
          ? null
          : CoachToolCallParser.tryParse(fullText);

      if (toolCall == null) {
        // Always strip — a leaked or malformed TOOL_CALL directive must never
        // reach the athlete verbatim, even if that leaves an empty answer
        // (surfaced upstream as a retryable "empty response" error).
        final finalText = CoachToolCallParser.stripToolCallMarkup(fullText);
        _setAssistantContent(
          assistantId,
          finalText,
          toolSteps: List.of(toolSteps),
          visualArtifacts: visualArtifacts,
          findings: findings,
          pendingActions: pendingActions,
        );
        return;
      }

      final callKey = '${toolCall.name}:${jsonEncode(toolCall.arguments)}';
      if (!executedCalls.add(callKey)) {
        toolResults.add(
          CoachToolResult(
            toolCall: toolCall,
            isError: true,
            promptSummary:
                'That exact tool request already ran. Answer using the existing result.',
            displayLabel: 'Skipped duplicate analysis',
          ),
        );
        nextUserMessage = _buildToolFollowUpPrompt(
          originalQuestion: userMessage,
          toolResults: toolResults,
          isFinalAttempt: true,
          backend: chatRepository.lastBackend,
          cloudLevel: cloudLevel,
        );
        contextForThisCall = null;
        continue;
      }

      final runningStep = CoachToolStep(
        toolName: toolCall.name,
        status: CoachToolStatus.running,
        displayLabel: CoachAgentToolCatalog.actionLabelFor(toolCall.name),
      );
      toolSteps.add(runningStep);
      _setAssistantToolSteps(assistantId, List.of(toolSteps));

      late final CoachToolResult result;
      try {
        result = await executeTool(
          toolCall: toolCall,
          context: coachContext,
          preferences: settings.contextPreferences,
        ).timeout(_toolTimeout);
      } on TimeoutException {
        result = CoachToolResult(
          toolCall: toolCall,
          isError: true,
          promptSummary: 'The local analysis timed out.',
          displayLabel: 'Analysis timed out',
        );
      }

      toolSteps[toolSteps.length - 1] = runningStep.copyWith(
        status: result.isError
            ? CoachToolStatus.error
            : CoachToolStatus.success,
        displayLabel: result.displayLabel,
      );
      _setAssistantToolSteps(assistantId, List.of(toolSteps));

      if (_cancelRequested) return;

      toolResults.add(result);
      visualArtifacts.addAll(
        result.visualArtifacts.take(4 - visualArtifacts.length),
      );
      findings.addAll(result.findings);
      pendingActions.addAll(result.pendingActions);
      _setAssistantContent(
        assistantId,
        _messageContent(assistantId),
        toolSteps: List.of(toolSteps),
        visualArtifacts: visualArtifacts,
        findings: findings,
        pendingActions: pendingActions,
      );
      nextUserMessage = _buildToolFollowUpPrompt(
        originalQuestion: userMessage,
        toolResults: toolResults,
        isFinalAttempt: step == _maxToolStepsPerTurn - 1,
        backend: chatRepository.lastBackend,
        cloudLevel: cloudLevel,
      );
      contextForThisCall = null;
    }
  }

  String _buildToolFollowUpPrompt({
    required String originalQuestion,
    required List<CoachToolResult> toolResults,
    required bool isFinalAttempt,
    required AiInferenceBackend backend,
    required CloudDataLevel cloudLevel,
  }) {
    final resultLines = toolResults
        .map((result) {
          final summary = _toolSummaryForBackend(
            result.promptSummary,
            backend,
            cloudLevel,
          );
          return result.isError
              ? 'Tool `${result.toolCall.name}` could not run: $summary'
              : 'Tool `${result.toolCall.name}` result: $summary';
        })
        .join('\n');
    final instruction = isFinalAttempt
        ? 'Give your final answer to the person now. Do not call another tool.'
        : 'If you still need more data, reply with another single TOOL_CALL '
              'line. Otherwise answer the person now.';
    return '$resultLines\n\n'
        'Continue answering the person\'s question: "$originalQuestion"\n'
        '$instruction Do not mention tools or TOOL_CALL in your reply.';
  }

  String _toolSummaryForBackend(
    String summary,
    AiInferenceBackend backend,
    CloudDataLevel cloudLevel,
  ) {
    if (backend != AiInferenceBackend.openRouter) return summary;
    return switch (cloudLevel) {
      CloudDataLevel.none =>
        'The requested analysis completed locally, but health-derived results '
            'are not shared with cloud models.',
      CloudDataLevel.minimal =>
        summary
            .replaceAll(RegExp(r'\b\d{4}-\d{2}-\d{2}\b'), 'a recent date')
            .replaceAll(RegExp(r'\b\d+(?:\.\d+)?\b'), 'a rounded value'),
      CloudDataLevel.standard || CloudDataLevel.full => summary,
    };
  }

  void _appendAssistantContent(String assistantId, String textToAppend) {
    if (textToAppend.isEmpty) return;
    final msgs = state.value;
    if (msgs == null) return;
    final idx = msgs.indexWhere((m) => m.id == assistantId);
    if (idx == -1) return;
    final updated = msgs[idx].copyWith(
      content: msgs[idx].content + textToAppend,
    );
    state = AsyncData(List<ChatMessage>.from(msgs)..[idx] = updated);
  }

  void _setAssistantContent(
    String assistantId,
    String content, {
    required List<CoachToolStep> toolSteps,
    required List<HealthVisualArtifact> visualArtifacts,
    required List<HealthFinding> findings,
    required List<PendingCoachAction> pendingActions,
  }) {
    final msgs = state.value;
    if (msgs == null) return;
    final idx = msgs.indexWhere((m) => m.id == assistantId);
    if (idx == -1) return;
    final updated = msgs[idx].copyWith(
      content: content,
      toolSteps: toolSteps.isEmpty ? null : toolSteps,
      clearToolSteps: toolSteps.isEmpty,
      visualArtifacts: visualArtifacts.isEmpty
          ? null
          : List.of(visualArtifacts.take(4)),
      findings: findings.isEmpty ? null : List.of(findings),
      pendingActions: pendingActions.isEmpty ? null : List.of(pendingActions),
    );
    state = AsyncData(List<ChatMessage>.from(msgs)..[idx] = updated);
  }

  void _setAssistantToolSteps(
    String assistantId,
    List<CoachToolStep> toolSteps,
  ) {
    final msgs = state.value;
    if (msgs == null) return;
    final idx = msgs.indexWhere((m) => m.id == assistantId);
    if (idx == -1) return;
    final updated = msgs[idx].copyWith(toolSteps: toolSteps);
    state = AsyncData(List<ChatMessage>.from(msgs)..[idx] = updated);
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
      AiInferenceBackend.onDevice ||
      AiInferenceBackend.rulesOnly => AiInferenceBackend.openRouter,
      AiInferenceBackend.openRouter => AiInferenceBackend.onDevice,
      null => null,
    };
  }

  Future<CoachContext> _loadCoachContext(
    CoachConversationSettings settings,
  ) async {
    try {
      final conversation = await _loadConversation();
      final fullContext = await ref
          .read(
            coachContextForConversationProvider(
              seed: conversation?.seed,
            ).future,
          )
          .timeout(_healthContextTimeout);
      return ref
          .read(filterCoachContextUseCaseProvider)
          .call(context: fullContext, preferences: settings.contextPreferences);
    } on TimeoutException {
      _logger.w('Coach context timed out; using minimal context');
      return ref
          .read(buildCoachContextUseCaseProvider)
          .call(healthHistory: const [], recentRuns: const []);
    } on Object catch (error, stackTrace) {
      _logger.w(
        'Coach context unavailable; using minimal context',
        error: error,
        stackTrace: stackTrace,
      );
      return ref
          .read(buildCoachContextUseCaseProvider)
          .call(healthHistory: const [], recentRuns: const []);
    }
  }

  Future<CoachContext> _readCoachContextSafely(
    CoachConversationSettings settings,
  ) => _loadCoachContext(settings);

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
      conversation.copyWith(messages: messages, updatedAt: DateTime.now()),
    );
    await ref.read(coachConversationsProvider.notifier).refresh();
    ref.invalidate(activeCoachConversationProvider);
  }

  Future<CoachConversation?> _loadConversation() async {
    final conversationId = ref.read(activeCoachConversationIdProvider);
    if (conversationId == null) return null;
    final result = await ref
        .read(getCoachConversationUseCaseProvider)
        .call(conversationId);
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
