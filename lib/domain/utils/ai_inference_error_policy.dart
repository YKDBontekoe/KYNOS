import 'dart:async';

/// Classifies on-device LLM failures and maps them to user-facing copy.
abstract final class AiInferenceErrorPolicy {
  static const _recoverablePatterns = [
    'Failed to invoke the compiled model',
    'Stream error',
    'INTERNAL',
    'OUT_OF_MEMORY',
    'RESOURCE_EXHAUSTED',
    'Chat not initialized',
    'Resource limit',
    'litert',
    'compiled model',
    'timed out',
    'timeoutexception',
  ];

  static bool isRecoverable(Object error) {
    if (error is TimeoutException) return true;

    final message = _messageFor(error).toLowerCase();
    if (message.isEmpty) return false;
    for (final pattern in _recoverablePatterns) {
      if (message.contains(pattern.toLowerCase())) return true;
    }
    return false;
  }

  static String userFriendlyMessage(Object error) {
    final message = _messageFor(error);
    if (isRecoverable(error)) {
      if (error is TimeoutException ||
          message.toLowerCase().contains('timed out') ||
          message.contains('TimeoutException')) {
        return 'The on-device model took too long to respond. Tap Retry to try again.';
      }
      return 'The on-device model hit a resource limit. '
          'Tap Retry — we will switch to a safer inference mode.';
    }
    if (message.contains('No active Gemma model')) {
      return 'The on-device model is not installed. Complete model setup, then try again.';
    }
    return 'On-device coaching is temporarily unavailable. Tap Retry or ask again in a moment.';
  }

  static String _messageFor(Object error) {
    if (error is StateError) return error.message;
    return error.toString();
  }
}

/// Recovery steps applied after a recoverable on-device inference failure.
enum AiChatRecoveryAction {
  reloadChat,
  reloadModelCpu,
  respawnIsolate,
  none,
}

/// Maps retry attempt index (0-based) to the next recovery action.
abstract final class AiChatRecoveryPlan {
  static AiChatRecoveryAction actionBeforeRetry(int failedAttemptIndex) {
    return switch (failedAttemptIndex) {
      0 => AiChatRecoveryAction.reloadChat,
      1 => AiChatRecoveryAction.reloadModelCpu,
      2 => AiChatRecoveryAction.respawnIsolate,
      _ => AiChatRecoveryAction.none,
    };
  }

  /// Initial attempt plus three recovery escalations.
  static const maxAttempts = 4;
}
