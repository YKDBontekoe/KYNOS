import 'package:kynos/domain/entities/ai_inference_backend.dart';
import 'package:kynos/domain/entities/ai_task_kind.dart';
import 'package:kynos/domain/entities/chat_message.dart';
import 'package:kynos/domain/entities/cloud_data_level.dart';
import 'package:kynos/domain/entities/cloud_llm_endpoint.dart';
import 'package:kynos/domain/entities/coach/coach_context.dart';
import 'package:kynos/domain/entities/coach/coach_tool_definition.dart';
import 'package:kynos/domain/entities/health_summary.dart';
import 'package:kynos/domain/repositories/ai_coach_repository.dart';
import 'package:kynos/domain/repositories/cloud_ai_repository.dart';
import 'package:kynos/domain/utils/cloud_health_text_redactor.dart';
import 'package:kynos/domain/utils/coach_persona_prompt.dart';
import 'package:kynos/infrastructure/ai/gemma/coach_prompt_builder.dart';
import 'package:kynos/infrastructure/ai/secure_api_key_storage.dart';

/// Configuration for hybrid local/cloud coach routing.
class HybridAiCoachConfig {
  const HybridAiCoachConfig({
    required this.cloudTasksEnabled,
    required this.cloudDataLevel,
    required this.selectedModelId,
    required this.selectedModelName,
    this.cloudBaseUrl = CloudLlmEndpoint.openRouterBaseUrl,
  });

  final bool cloudTasksEnabled;
  final CloudDataLevel cloudDataLevel;
  final String? selectedModelId;
  final String? selectedModelName;
  final String cloudBaseUrl;

  bool get canUseCloud =>
      cloudTasksEnabled &&
      selectedModelId != null &&
      selectedModelId!.isNotEmpty;
}

typedef HybridAiCoachConfigReader = Future<HybridAiCoachConfig> Function();

/// Routes coach requests between on-device Gemma (isolate) and cloud LLM.
class HybridAiCoachRepository implements AiCoachRepository {
  HybridAiCoachRepository({
    required AiCoachRepository localRepository,
    required CloudAiRepository cloudRepository,
    required SecureApiKeyStorage keyStorage,
    required HybridAiCoachConfigReader configReader,
  }) : _local = localRepository,
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

  static final _cloudSystemPrompt =
      '${CoachPersonaPrompt.base}\n\n'
      '${CoachAgentToolCatalog.systemPromptBlock}';

  @override
  Stream<AiChunk> chat({
    required String userMessage,
    List<HealthSummary>? healthContext,
    CoachContext? coachContext,
    List<ChatMessage>? conversationHistory,
    AiTaskKind taskKind = AiTaskKind.coachChat,
    int estimatedPromptTokens = 0,
    AiInferenceBackend? preferredBackend,
    String? cloudModelIdOverride,
    CloudDataLevel? cloudDataLevelOverride,
  }) async* {
    final config = await _configReader();
    final apiKey = await _keyStorage.readCloudApiKey();
    final hasKey = apiKey != null && apiKey.isNotEmpty;
    final cloudAvailable =
        config.canUseCloud && hasKey && config.selectedModelId != null;

    final useCloud = switch (preferredBackend) {
      AiInferenceBackend.cloud => true,
      AiInferenceBackend.onDevice || AiInferenceBackend.rulesOnly => false,
      null => false,
    };

    if (useCloud) {
      if (!cloudAvailable) {
        throw StateError(
          'Cloud coach is not configured. Add a cloud API key, base URL, '
          'and model in Settings.',
        );
      }
      lastBackend = AiInferenceBackend.cloud;
      yield* _streamCloud(
        apiKey: apiKey,
        modelId: cloudModelIdOverride ?? config.selectedModelId!,
        baseUrl: config.cloudBaseUrl,
        userMessage: userMessage,
        healthContext: healthContext,
        coachContext: coachContext,
        conversationHistory: conversationHistory,
        cloudDataLevel: cloudDataLevelOverride ?? config.cloudDataLevel,
      );
      return;
    }

    lastBackend = AiInferenceBackend.onDevice;
    yield* _local.chat(
      userMessage: userMessage,
      healthContext: healthContext,
      coachContext: coachContext,
      conversationHistory: conversationHistory,
      taskKind: taskKind,
      estimatedPromptTokens: estimatedPromptTokens,
      preferredBackend: preferredBackend,
      cloudModelIdOverride: cloudModelIdOverride,
      cloudDataLevelOverride: cloudDataLevelOverride,
    );
    lastBackend = _local.lastBackend;
  }

  Stream<AiChunk> _streamCloud({
    required String apiKey,
    required String modelId,
    required String baseUrl,
    required String userMessage,
    required List<HealthSummary>? healthContext,
    required CoachContext? coachContext,
    required List<ChatMessage>? conversationHistory,
    required CloudDataLevel cloudDataLevel,
  }) async* {
    final cloudSafeUserMessage = CloudHealthTextRedactor.redact(userMessage);
    final contextBlock = buildCoachUserMessage(
      '',
      healthContext,
      coachContext: coachContext,
      cloudLevel: cloudDataLevel,
    ).trim();

    final userTurn = StringBuffer()..writeln(cloudSafeUserMessage);
    if (contextBlock.isNotEmpty) {
      userTurn
        ..writeln()
        ..writeln(contextBlock);
    }

    var emitted = false;
    // Cloud turns are intentionally stateless: previous free-form messages may
    // contain notes, symptom wording, or exact health values.
    final stream = _cloud.streamCompletion(
      apiKey: apiKey,
      modelId: modelId,
      baseUrl: baseUrl,
      systemPrompt: _cloudSystemPrompt,
      userPrompt: userTurn.toString(),
    );

    await for (final chunk in stream) {
      emitted = true;
      yield chunk;
    }

    if (!emitted) {
      throw StateError('Cloud coach returned an empty response');
    }
  }

  @override
  Future<void> resetSession() => _local.resetSession();

  @override
  Future<void> dispose() => _local.dispose();
}
