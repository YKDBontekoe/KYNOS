import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:kynos/core/constants/app_constants.dart';
import 'package:kynos/domain/entities/health_summary.dart';
import 'package:kynos/domain/repositories/ai_coach_repository.dart';

/// Direct flutter_gemma implementation of [AiCoachRepository].
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

    try {
      _model ??= await FlutterGemma.getActiveModel(
        maxTokens: AppConstants.modelContextWindow,
        preferredBackend: PreferredBackend.cpu,
      );
    } on StateError catch (e) {
      final normalized = e.toString().toLowerCase();
      final noActiveModel =
          normalized.contains('no active inference model set') ||
          (normalized.contains('no active') && normalized.contains('model'));
      if (noActiveModel) {
        throw Exception(
          'No active Gemma model is installed. Complete model setup before starting chat.',
        );
      }
      rethrow;
    }

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

    final model = _model;
    if (model == null) {
      throw Exception('Model session unavailable');
    }

    final session = model.session;
    if (session == null) {
      throw Exception('Model session unavailable');
    }

    await session.addQueryChunk(
      Message.text(text: userMessage, isUser: true),
    );

    final fullResponse = await session.getResponse();
    final words = fullResponse.split(' ');
    for (var i = 0; i < words.length; i++) {
      yield i == 0 ? words[i] : ' ${words[i]}';
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
