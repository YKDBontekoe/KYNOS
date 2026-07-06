import 'package:kynos/domain/entities/cloud_data_level.dart';
import 'package:kynos/core/errors/failures.dart';
import 'package:kynos/domain/entities/ai_inference_backend.dart';
import 'package:kynos/domain/entities/ai_task_kind.dart';
import 'package:kynos/domain/entities/chat_message.dart';
import 'package:kynos/domain/entities/coach/coach_context.dart';
import 'package:kynos/domain/entities/health_summary.dart';
import 'package:kynos/domain/entities/on_device_model.dart';
import 'package:kynos/domain/repositories/ai_coach_repository.dart';
import 'package:kynos/domain/repositories/ai_model_repository.dart';

class FakeAiCoachRepository implements AiCoachRepository {
  @override
  bool get isReady => false;

  @override
  AiInferenceBackend lastBackend = AiInferenceBackend.onDevice;

  @override
  Stream<String> chat({
    required String userMessage,
    List<HealthSummary>? healthContext,
    CoachContext? coachContext,
    List<ChatMessage>? conversationHistory,
    AiTaskKind taskKind = AiTaskKind.coachChat,
    int estimatedPromptTokens = 0,
    AiInferenceBackend? preferredBackend,
    String? cloudModelIdOverride,
    CloudDataLevel? cloudDataLevelOverride,
  }) async* {}

  @override
  Future<void> dispose() async {}

  @override
  Future<void> resetSession() async {}
}

class FakeAiModelRepository implements AiModelRepository {
  FakeAiModelRepository({required this.hasActiveModel});

  @override
  final bool hasActiveModel;

  @override
  String? get installedModelId => null;

  @override
  Future<({Failure? failure})> initialize({String? huggingFaceToken}) async =>
      (failure: null);

  @override
  Future<({Failure? failure})> install(
    OnDeviceModel model, {
    String? token,
  }) async =>
      (failure: null);

  @override
  bool isActiveModel(String catalogId) => false;
}
