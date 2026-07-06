import 'package:flutter_test/flutter_test.dart';
import 'package:kynos/domain/entities/ai_task_kind.dart';
import 'package:kynos/domain/utils/ai_task_router.dart';

void main() {
  group('AiTaskRouter.shouldUseCloud', () {
    test('uses cloud for coach chat when cloud is fully configured', () {
      expect(
        AiTaskRouter.shouldUseCloud(
          kind: AiTaskKind.coachChat,
          cloudTasksEnabled: true,
          hasApiKey: true,
          hasSelectedModel: true,
          estimatedPromptTokens: 12,
        ),
        isTrue,
      );
    });

    test('does not use cloud for coach chat when cloud tasks are disabled', () {
      expect(
        AiTaskRouter.shouldUseCloud(
          kind: AiTaskKind.coachChat,
          cloudTasksEnabled: false,
          hasApiKey: true,
          hasSelectedModel: true,
          estimatedPromptTokens: 1200,
        ),
        isFalse,
      );
    });

    test('does not use cloud for quick refine tasks', () {
      expect(
        AiTaskRouter.shouldUseCloud(
          kind: AiTaskKind.quickRefine,
          cloudTasksEnabled: true,
          hasApiKey: true,
          hasSelectedModel: true,
          estimatedPromptTokens: 1200,
        ),
        isFalse,
      );
    });
  });
}
