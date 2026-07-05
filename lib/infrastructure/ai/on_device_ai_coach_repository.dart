import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:kynos/domain/entities/ai_inference_backend.dart';
import 'package:kynos/domain/entities/ai_task_kind.dart';
import 'package:kynos/domain/entities/health_summary.dart';
import 'package:kynos/domain/repositories/ai_coach_repository.dart';
import 'package:kynos/domain/utils/health_context_formatter.dart';
import 'package:kynos/infrastructure/ai/gemma/gemma_runtime.dart';

/// LiteRT-LM / flutter_gemma implementation of [AiCoachRepository].
///
/// Runs entirely on-device — no data leaves the device at inference time.
class OnDeviceAiCoachRepository implements AiCoachRepository {
  InferenceModel? _model;
  InferenceChat? _chat;

  @override
  bool get isReady => _chat != null;

  @override
  AiInferenceBackend lastBackend = AiInferenceBackend.onDevice;

  static const String _systemInstruction =
      'You are KYNOS Coach — an expert on-device running coach. '
      'Give concise, biomechanics-aware advice. '
      'Never reveal you are an AI model or reference any training data.';

  Future<void> _ensureReady({String? huggingFaceToken}) async {
    if (_chat != null) return;
    await GemmaRuntime.initialize(huggingFaceToken: huggingFaceToken);
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
    AiTaskKind taskKind = AiTaskKind.coachChat,
    int estimatedPromptTokens = 0,
  }) async* {
    await _ensureReady();
    lastBackend = AiInferenceBackend.onDevice;

    final prompt = _buildPrompt(userMessage, healthContext);
    await _chat!.addQueryChunk(Message.text(text: prompt, isUser: true));
    await for (final response in _chat!.generateChatResponseAsync()) {
      if (response is TextResponse) {
        yield response.token;
      }
    }
  }

  String _buildPrompt(String userMessage, List<HealthSummary>? healthContext) {
    if (healthContext == null || healthContext.isEmpty) return userMessage;
    final lines = HealthContextFormatter.summarizeForPrompt(healthContext);
    return 'Recent athlete metrics:\n${lines.join('\n')}\n\n'
        'Athlete question: $userMessage';
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
