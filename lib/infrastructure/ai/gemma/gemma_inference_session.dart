import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:kynos/domain/entities/coach/coach_tool_definition.dart';
import 'package:kynos/domain/utils/gemma_device_capability.dart';
import 'package:kynos/domain/utils/gemma_inference_limits.dart';
import 'package:kynos/infrastructure/ai/gemma/ai_isolate_messages.dart';

const _baseCoachSystemInstruction =
    'You are KYNOS Coach — an expert on-device running coach. '
    'Give concise, biomechanics-aware advice. Lead with the daily recommendation, '
    'then cite 2–3 provided evidence signals and state confidence. '
    'Never invent metrics, zones, injuries, or training history. '
    'Never reveal you are an AI model or reference any training data.';

/// Legacy alias kept for callers/tests that reference the base instruction.
const coachSystemInstruction = _baseCoachSystemInstruction;

/// Tier-aware system instruction. Agentic tool calling is only offered on
/// [GemmaInferenceTier.full] devices — lower tiers have too little context
/// budget (see [GemmaInferenceLimits]) to reliably run a multi-step tool loop.
String coachSystemInstructionFor(GemmaInferenceTier tier) {
  if (tier != GemmaInferenceTier.full) return _baseCoachSystemInstruction;
  return '$_baseCoachSystemInstruction\n\n'
      '${CoachAgentToolCatalog.systemPromptBlock}';
}

PreferredBackend preferredBackendFromMessage(AiPreferredBackend backend) =>
    backend == AiPreferredBackend.gpu
    ? PreferredBackend.gpu
    : PreferredBackend.cpu;

AiPreferredBackend preferredBackendFromTier(GemmaInferenceTier tier) =>
    tier == GemmaInferenceTier.full
    ? AiPreferredBackend.gpu
    : AiPreferredBackend.cpu;

/// Loads or reloads the active Gemma model and chat session inside the isolate.
Future<({InferenceModel model, InferenceChat chat})> loadGemmaCoachSession({
  required GemmaInferenceTier tier,
  required AiPreferredBackend backend,
  InferenceModel? existingModel,
}) async {
  final maxTokens = GemmaInferenceLimits.maxContextTokens(tier);
  final maxOutputTokens = GemmaInferenceLimits.maxOutputTokens(tier);
  final preferredBackend = preferredBackendFromMessage(backend);

  await existingModel?.close();

  final model = await FlutterGemma.getActiveModel(
    maxTokens: maxTokens,
    preferredBackend: preferredBackend,
  );

  final chat = await model.createChat(
    systemInstruction: coachSystemInstructionFor(tier),
    maxOutputTokens: maxOutputTokens,
  );

  return (model: model, chat: chat);
}

Future<InferenceChat> recreateCoachChat({
  required InferenceModel model,
  required GemmaInferenceTier tier,
}) async {
  final maxOutputTokens = GemmaInferenceLimits.maxOutputTokens(tier);
  return model.createChat(
    systemInstruction: coachSystemInstructionFor(tier),
    maxOutputTokens: maxOutputTokens,
  );
}
