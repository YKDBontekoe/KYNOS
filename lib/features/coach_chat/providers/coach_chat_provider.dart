import 'package:kynos/domain/entities/ai_inference_backend.dart';
import 'package:kynos/domain/entities/chat_message.dart';
import 'package:kynos/domain/entities/health_summary.dart';
import 'package:kynos/domain/utils/ai_inference_error_policy.dart';
import 'package:kynos/domain/utils/coach_fallback_reply.dart';
import 'package:kynos/shared/providers/ai_repository_providers.dart';
import 'package:kynos/shared/providers/health_providers.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'coach_chat_provider.g.dart';

@Riverpod(keepAlive: true)
class CoachChatNotifier extends _$CoachChatNotifier {
  final _logger = Logger();

  @override
  Future<List<ChatMessage>> build() async {
    return const [];
  }

  Future<void> sendMessage(String userMessage) async {
    await _runInference(userMessage: userMessage);
  }

  Future<void> retryMessage(String assistantId) async {
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

  Future<void> _runInference({
    required String userMessage,
    String? existingAssistantId,
  }) async {
    final current = state.value ?? const [];

    late final String assistantId;
    List<ChatMessage> workingMessages;

    if (existingAssistantId != null) {
      assistantId = existingAssistantId;
      workingMessages = List<ChatMessage>.from(current);
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
      workingMessages = [...current, userMsg, placeholder];
      state = AsyncData(workingMessages);
    }

    try {
      final repository = ref.read(aiCoachRepositoryProvider);
      final healthContext = await ref.read(
        healthHistoryProvider(days: 14).future,
      );

      final estimatedTokens = _estimateTokens(userMessage, healthContext);

      await for (final chunk in repository.chat(
        userMessage: userMessage,
        healthContext: healthContext,
        estimatedPromptTokens: estimatedTokens,
      )) {
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
      _finaliseMessage(assistantId, streaming: false, hasError: false);
    } catch (e, st) {
      _logger.e('Inference error', error: e, stackTrace: st);
      final healthContext = await _readHealthContextSafely();

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
    }
  }

  int _estimateTokens(String message, List<HealthSummary> healthContext) {
    final chars = message.length + healthContext.length * 80;
    return (chars / 4).round();
  }

  Future<List<HealthSummary>> _readHealthContextSafely() async {
    try {
      return await ref.read(healthHistoryProvider(days: 14).future);
    } on Object {
      return const [];
    }
  }

  Future<void> clearConversation() async {
    state = const AsyncData([]);
    await ref.read(aiCoachRepositoryProvider).resetSession();
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
}

@Riverpod(keepAlive: true)
class LastAiInferenceBackend extends _$LastAiInferenceBackend {
  @override
  AiInferenceBackend build() => AiInferenceBackend.onDevice;

  void set(AiInferenceBackend backend) => state = backend;
}
