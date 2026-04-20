import 'package:kynos/domain/entities/health_summary.dart';

/// Streaming response chunk from the on-device LLM.
typedef AiChunk = String;

/// Contract for the on-device AI coaching engine.
///
/// The implementation runs entirely via on-device inference (flutter_gemma /
/// MediaPipe) to preserve 120 Hz ProMotion rendering on the UI thread.
abstract interface class AiCoachRepository {
  /// Whether the on-device model is loaded and ready.
  bool get isReady;

  /// Sends [userMessage] with optional [healthContext] and returns a stream
  /// of response chunks (streaming token-by-token output).
  Stream<AiChunk> chat({
    required String userMessage,
    List<HealthSummary>? healthContext,
  });

  /// Discards the current chat session and starts a fresh one.
  ///
  /// Keeps the model weights loaded — cheaper than a full [dispose] + reload.
  Future<void> resetSession();

  /// Releases the model from memory (e.g., when the app backgrounds).
  Future<void> dispose();
}
