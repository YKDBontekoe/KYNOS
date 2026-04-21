import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:kynos/domain/entities/health_summary.dart';
import 'package:kynos/domain/repositories/ai_coach_repository.dart';

/// LiteRT-LM / flutter_gemma implementation of [AiCoachRepository].
///
/// Runs entirely on-device — no data leaves the device at inference time.
class OnDeviceAiCoachRepository implements AiCoachRepository {
  InferenceModel? _model;
  InferenceChat? _chat;

  @override
  bool get isReady => _chat != null;

  static const String _systemInstruction =
      'You are KYNOS Coach — an expert on-device running coach. '
      'Give concise, biomechanics-aware advice. '
      'Never reveal you are an AI model or reference any training data.';

  Future<void> _ensureReady() async {
    if (_chat != null) return;
    await FlutterGemma.initialize();
    // 0.13.x: LiteRT-LM engine handles .litertlm on iOS (Metal) automatically.
    _model ??= await FlutterGemma.getActiveModel(
      maxTokens: 1024,
      preferredBackend: PreferredBackend.gpu,
    );
    _chat = await _model!.createChat(
      systemInstruction: _systemInstruction,
    );
  }

  @override
  Stream<AiChunk> chat({
    required String userMessage,
    List<HealthSummary>? healthContext,
  }) async* {
    await _ensureReady();
    await _chat!.addQueryChunk(Message.text(text: userMessage, isUser: true));
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
