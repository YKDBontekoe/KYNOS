import 'package:kynos/domain/entities/ai_task_kind.dart';

/// Routes AI tasks to local Gemma or OpenRouter cloud backends.
abstract final class AiTaskRouter {
  /// Short coach messages stay on-device; longer prompts may use cloud when enabled.
  static const int coachChatCloudTokenThreshold = 800;

  /// Whether this task may use OpenRouter when cloud is enabled.
  static bool isCloudEligible(AiTaskKind kind) {
    return switch (kind) {
      AiTaskKind.quickRefine => false,
      AiTaskKind.coachChat => true,
      AiTaskKind.trainingPlan => true,
      AiTaskKind.runDebrief => true,
      AiTaskKind.dataQuery => true,
    };
  }

  /// Whether cloud should be used for this request.
  static bool shouldUseCloud({
    required AiTaskKind kind,
    required bool cloudTasksEnabled,
    required bool hasApiKey,
    required bool hasSelectedModel,
    required int estimatedPromptTokens,
  }) {
    if (!cloudTasksEnabled || !hasApiKey || !hasSelectedModel) return false;
    if (!isCloudEligible(kind)) return false;

    return switch (kind) {
      AiTaskKind.coachChat =>
        estimatedPromptTokens >= coachChatCloudTokenThreshold,
      _ => true,
    };
  }
}
