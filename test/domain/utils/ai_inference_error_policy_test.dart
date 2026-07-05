import 'package:flutter_test/flutter_test.dart';
import 'package:kynos/domain/utils/ai_inference_error_policy.dart';

void main() {
  group('AiInferenceErrorPolicy', () {
    test('marks LiteRT invoke failures as recoverable', () {
      final error = StateError(
        'Exception: Stream error: INTERNAL: ERROR: '
        '[runtime/executor/llm_litert_compiled_model_executor.cc:734] '
        'Failed to invoke the compiled model',
      );
      expect(AiInferenceErrorPolicy.isRecoverable(error), isTrue);
    });

    test('marks chat init failures as recoverable', () {
      expect(
        AiInferenceErrorPolicy.isRecoverable(StateError('Chat not initialized')),
        isTrue,
      );
    });

    test('marks unrelated errors as non-recoverable', () {
      expect(
        AiInferenceErrorPolicy.isRecoverable(Exception('Invalid API key')),
        isFalse,
      );
    });

    test('maps recoverable errors to friendly copy', () {
      final error = StateError('Stream error: INTERNAL');
      final message = AiInferenceErrorPolicy.userFriendlyMessage(error);
      expect(message, contains('Tap Retry'));
      expect(message, isNot(contains('INTERNAL')));
    });
  });

  group('AiChatRecoveryPlan', () {
    test('returns escalating recovery actions', () {
      expect(
        AiChatRecoveryPlan.actionBeforeRetry(0),
        AiChatRecoveryAction.reloadChat,
      );
      expect(
        AiChatRecoveryPlan.actionBeforeRetry(1),
        AiChatRecoveryAction.reloadModelCpu,
      );
      expect(
        AiChatRecoveryPlan.actionBeforeRetry(2),
        AiChatRecoveryAction.respawnIsolate,
      );
      expect(
        AiChatRecoveryPlan.actionBeforeRetry(3),
        AiChatRecoveryAction.none,
      );
    });
  });
}
