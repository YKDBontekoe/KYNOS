import 'package:kynos/domain/entities/ai_inference_backend.dart';
import 'package:kynos/domain/entities/ai_task_kind.dart';
import 'package:kynos/domain/entities/chat_message.dart';
import 'package:kynos/domain/entities/coach/coach_context.dart';
import 'package:kynos/domain/entities/health_summary.dart';

/// Streaming response chunk from the on-device or cloud LLM.
typedef AiChunk = String;

/// Contract for the AI coaching engine (local Gemma + optional OpenRouter).
abstract interface class AiCoachRepository {
  /// Whether a local on-device model is loaded and ready.
  bool get isReady;

  /// Backend used for the most recent [chat] call.
  AiInferenceBackend get lastBackend;

  /// Sends [userMessage] with optional [healthContext] and returns a stream
  /// of response chunks (streaming token-by-token output).
  Stream<AiChunk> chat({
    required String userMessage,
    List<HealthSummary>? healthContext,
    CoachContext? coachContext,
    List<ChatMessage>? conversationHistory,
    AiTaskKind taskKind = AiTaskKind.coachChat,
    int estimatedPromptTokens = 0,
    AiInferenceBackend? preferredBackend,
  });

  /// Discards the current chat session and starts a fresh one.
  Future<void> resetSession();

  /// Releases model resources (e.g., when the app backgrounds).
  Future<void> dispose();
}
