import 'package:kynos/domain/entities/ai_inference_backend.dart';
import 'package:kynos/domain/entities/ai_task_kind.dart';
import 'package:kynos/domain/entities/chat_message.dart';
import 'package:kynos/domain/entities/coach/coach_context.dart';
import 'package:kynos/domain/repositories/ai_coach_repository.dart';

/// Streams a coach reply with unified runner context and optional history.
class SendCoachMessageUseCase {
  const SendCoachMessageUseCase({required AiCoachRepository aiCoachRepository})
      : _aiCoachRepository = aiCoachRepository;

  final AiCoachRepository _aiCoachRepository;

  static const maxHistoryMessages = 12;

  Stream<String> call({
    required String userMessage,
    CoachContext? coachContext,
    List<ChatMessage>? conversationHistory,
    AiInferenceBackend? preferredBackend,
  }) {
    final history = _trimHistory(conversationHistory);
    final estimatedTokens = _estimateTokens(
      userMessage,
      coachContext,
      history,
    );

    return _aiCoachRepository.chat(
      userMessage: userMessage,
      healthContext: coachContext?.healthHistory,
      coachContext: coachContext,
      conversationHistory: history,
      taskKind: AiTaskKind.coachChat,
      estimatedPromptTokens: estimatedTokens,
      preferredBackend: preferredBackend,
    );
  }

  List<ChatMessage> _trimHistory(List<ChatMessage>? history) {
    if (history == null || history.isEmpty) return const [];
    final completed = history
        .where((m) => !m.isStreaming && m.content.trim().isNotEmpty)
        .toList();
    if (completed.length <= maxHistoryMessages) return completed;
    return completed.sublist(completed.length - maxHistoryMessages);
  }

  int _estimateTokens(
    String message,
    CoachContext? context,
    List<ChatMessage> history,
  ) {
    var chars = message.length;
    if (context != null) {
      chars += context.healthHistory.length * 80 + 400;
    }
    for (final msg in history) {
      chars += msg.content.length;
    }
    return (chars / 4).round();
  }
}
