import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:kynos/domain/entities/health_summary.dart';
import 'package:kynos/domain/repositories/ai_coach_repository.dart';

/// MediaPipe / flutter_gemma implementation of [AiCoachRepository].
///
/// Runs entirely on-device — no data leaves the device at inference time.
class OnDeviceAiCoachRepository implements AiCoachRepository {
  InferenceModel? _model;
  InferenceChat? _chat;

  @override
  bool get isReady => _chat != null;

  Future<void> _ensureReady() async {
    if (_chat != null) return;
    await FlutterGemma.initialize();
    _model ??= await FlutterGemma.getActiveModel(
      maxTokens: 512,
      preferredBackend: PreferredBackend.gpu,
    );
    _chat = await _model!.createChat();
  }

  @override
  Stream<AiChunk> chat({
    required String userMessage,
    List<HealthSummary>? healthContext,
  }) async* {
    await _ensureReady();
    final prompt = 'You are KYNOS coach.\n\n$userMessage';
    await _chat!.addQueryChunk(Message.text(text: prompt, isUser: true));
    await for (final response in _chat!.generateChatResponseAsync()) {
      if (response is TextResponse) {
        yield response.token;
      }
    }
  }

  @override
  Future<void> resetSession() async {
    await _chat?.clearHistory();
  }

  @override
  Future<void> dispose() async {
    await _model?.close();
    _model = null;
    _chat = null;
  }
}
