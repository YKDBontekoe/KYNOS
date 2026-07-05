import 'package:kynos/domain/entities/ai_inference_backend.dart';
import 'package:kynos/domain/entities/ai_task_kind.dart';
import 'package:kynos/domain/entities/cloud_data_level.dart';
import 'package:kynos/domain/entities/health_summary.dart';
import 'package:kynos/domain/repositories/ai_coach_repository.dart';
import 'package:kynos/domain/repositories/cloud_ai_repository.dart';
import 'package:kynos/domain/utils/health_context_formatter.dart';
import 'package:kynos/infrastructure/ai/ai_task_router.dart';
import 'package:kynos/infrastructure/ai/secure_api_key_storage.dart';

/// Configuration for hybrid local/cloud coach routing.
class HybridAiCoachConfig {
  const HybridAiCoachConfig({
    required this.cloudTasksEnabled,
    required this.cloudDataLevel,
    required this.selectedModelId,
    required this.selectedModelName,
  });

  final bool cloudTasksEnabled;
  final CloudDataLevel cloudDataLevel;
  final String? selectedModelId;
  final String? selectedModelName;

  bool get canUseCloud =>
      cloudTasksEnabled &&
      selectedModelId != null &&
      selectedModelId!.isNotEmpty;
}

typedef HybridAiCoachConfigReader = Future<HybridAiCoachConfig> Function();

/// Routes coach requests between on-device Gemma (isolate) and OpenRouter.
class HybridAiCoachRepository implements AiCoachRepository {
  HybridAiCoachRepository({
    required AiCoachRepository localRepository,
    required CloudAiRepository cloudRepository,
    required SecureApiKeyStorage keyStorage,
    required HybridAiCoachConfigReader configReader,
  })  : _local = localRepository,
        _cloud = cloudRepository,
        _keyStorage = keyStorage,
        _configReader = configReader;

  final AiCoachRepository _local;
  final CloudAiRepository _cloud;
  final SecureApiKeyStorage _keyStorage;
  final HybridAiCoachConfigReader _configReader;

  @override
  bool get isReady => _local.isReady;

  @override
  AiInferenceBackend lastBackend = AiInferenceBackend.onDevice;

  static const _cloudSystemPrompt =
      'You are KYNOS Coach — an expert running coach. '
      'Give actionable, biomechanics-aware advice. '
      'Never invent metrics not provided in context.';

  @override
  Stream<AiChunk> chat({
    required String userMessage,
    List<HealthSummary>? healthContext,
    AiTaskKind taskKind = AiTaskKind.coachChat,
    int estimatedPromptTokens = 0,
  }) async* {
    final config = await _configReader();
    final apiKey = await _keyStorage.readOpenRouterKey();
    final hasKey = apiKey != null && apiKey.isNotEmpty;

    final useCloud = AiTaskRouter.shouldUseCloud(
      kind: taskKind,
      cloudTasksEnabled: config.cloudTasksEnabled,
      hasApiKey: hasKey,
      hasSelectedModel: config.selectedModelId != null,
      estimatedPromptTokens: estimatedPromptTokens,
    );

    if (useCloud && apiKey != null && config.selectedModelId != null) {
      lastBackend = AiInferenceBackend.openRouter;
      final contextLines = HealthContextFormatter.summarizeForPrompt(
        healthContext ?? const [],
        level: config.cloudDataLevel,
      );
      final userPrompt = StringBuffer()..writeln(userMessage);
      if (contextLines.isNotEmpty) {
        userPrompt
          ..writeln()
          ..writeln('Athlete context:')
          ..writeln(contextLines.join('\n'));
      }

      yield* _cloud.streamCompletion(
        apiKey: apiKey,
        modelId: config.selectedModelId!,
        systemPrompt: _cloudSystemPrompt,
        userPrompt: userPrompt.toString(),
      );
      return;
    }

    yield* _local.chat(
      userMessage: userMessage,
      healthContext: healthContext,
      taskKind: taskKind,
      estimatedPromptTokens: estimatedPromptTokens,
    );
    lastBackend = _local.lastBackend;
  }

  @override
  Future<void> resetSession() => _local.resetSession();

  @override
  Future<void> dispose() => _local.dispose();
}
