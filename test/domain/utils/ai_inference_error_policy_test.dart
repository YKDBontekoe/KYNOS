import 'dart:async';

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

    test('marks TimeoutException as recoverable', () {
      expect(
        AiInferenceErrorPolicy.isRecoverable(
          TimeoutException('AI isolate init timed out'),
        ),
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

    test('maps timeout errors to timeout-friendly copy', () {
      final message = AiInferenceErrorPolicy.userFriendlyMessage(
        TimeoutException('chat timed out'),
      );
      expect(message, contains('too long'));
    });

    test('maps chat init failures to setup guidance', () {
      final message = AiInferenceErrorPolicy.userFriendlyMessage(
        StateError('Chat not initialized'),
        canSwitchToCloud: true,
      );
      expect(message, contains('session is not ready'));
      expect(message, contains('cloud coaching'));
    });

    test('does not treat resource-not-found as resource limit', () {
      expect(
        AiInferenceErrorPolicy.isResourceLimitError(
          StateError('RESOURCE_NOT_FOUND: model missing'),
        ),
        isFalse,
      );
    });

    test('maps resource limit errors with cloud switch hint', () {
      final message = AiInferenceErrorPolicy.userFriendlyMessage(
        StateError('RESOURCE_EXHAUSTED: too many resources'),
        canSwitchToCloud: true,
      );
      expect(message, contains('too many resources'));
      expect(message, contains('Try cloud coach'));
    });

    test('maps cloud auth failures to settings hint', () {
      final message = AiInferenceErrorPolicy.userFriendlyMessage(
        StateError('Cloud LLM request failed (401 Unauthorized)'),
      );
      expect(message, contains('cloud API key'));
    });

    test('maps empty coach responses to retry hint', () {
      final message = AiInferenceErrorPolicy.userFriendlyMessage(
        StateError('Coach returned an empty response'),
      );
      expect(message, contains('no text'));
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

    test('maxAttempts allows full recovery escalation', () {
      final actions = <AiChatRecoveryAction>[];
      const recoverableError = 'Stream error: INTERNAL';
      final error = StateError(recoverableError);

      for (var attempt = 0; attempt < AiChatRecoveryPlan.maxAttempts; attempt++) {
        final canRetry = attempt < AiChatRecoveryPlan.maxAttempts - 1 &&
            AiInferenceErrorPolicy.isRecoverable(error);
        if (!canRetry) break;
        actions.add(AiChatRecoveryPlan.actionBeforeRetry(attempt));
      }

      expect(actions, [
        AiChatRecoveryAction.reloadChat,
        AiChatRecoveryAction.reloadModelCpu,
        AiChatRecoveryAction.respawnIsolate,
      ]);
    });
  });
}
