import 'dart:async';

/// Classifies on-device LLM failures and maps them to user-facing copy.
abstract final class AiInferenceErrorPolicy {
  static const _resourceLimitQualifiers = [
    'out_of_memory',
    'out of memory',
    'resource_exhausted',
    'resource exhausted',
    'too many resources',
    'too much memory',
    'resource limit',
  ];

  static const _otherRecoverablePatterns = [
    'Failed to invoke the compiled model',
    'Stream error',
    'INTERNAL',
    'Chat not initialized',
    'litert',
    'compiled model',
    'timed out',
    'timeoutexception',
  ];

  static bool isRecoverable(Object error) {
    if (error is TimeoutException) return true;

    final message = _messageFor(error).toLowerCase();
    if (message.isEmpty) return false;
    for (final pattern in [
      ..._resourceLimitQualifiers,
      ..._otherRecoverablePatterns,
    ]) {
      if (message.contains(pattern.toLowerCase())) return true;
    }
    return false;
  }

  static bool isResourceLimitError(Object error) {
    final message = _messageFor(error).toLowerCase();
    if (_resourceLimitQualifiers.any(message.contains)) return true;
    return message.contains('resource') &&
        (message.contains('exhaust') ||
            message.contains('limit') ||
            message.contains('too many'));
  }

  static String userFriendlyMessage(
    Object error, {
    bool canSwitchToCloud = false,
    bool canSwitchToOnDevice = false,
  }) {
    final message = _messageFor(error);
    if (_isCloudError(message)) {
      if (message.contains('401') || message.toLowerCase().contains('unauthorized')) {
        return 'Your cloud API key was rejected. Check Settings → AI & Cloud, then tap Retry.';
      }
      if (error is TimeoutException ||
          message.toLowerCase().contains('timed out') ||
          message.contains('TimeoutException')) {
        return canSwitchToOnDevice
            ? 'The cloud coach took too long to respond. Retry on cloud, or try on-device coaching instead.'
            : 'The cloud coach took too long to respond. Tap Retry to try again.';
      }
      if (message.toLowerCase().contains('empty response')) {
        return 'The cloud coach returned no text. Retry, choose a different model in Settings, or try on-device coaching.';
      }
      return canSwitchToOnDevice
          ? 'Cloud coaching failed. Retry on cloud, or try on-device coaching instead.'
          : 'Cloud coaching is temporarily unavailable. Tap Retry to try again.';
    }
    if (isResourceLimitError(error)) {
      return canSwitchToCloud
          ? 'The on-device model used too many resources on this device. '
              'Tap Retry to try a lighter on-device mode, or use Try cloud coach if you have a cloud endpoint configured.'
          : 'The on-device model used too many resources on this device. '
              'Close other apps, wait a moment, then tap Retry to try a lighter on-device mode.';
    }
    if (isRecoverable(error)) {
      if (error is TimeoutException ||
          message.toLowerCase().contains('timed out') ||
          message.contains('TimeoutException')) {
        return canSwitchToCloud
            ? 'The on-device model took too long to respond. Retry on-device, or try cloud coaching instead.'
            : 'The on-device model took too long to respond. Tap Retry to try again.';
      }
      if (_isChatInitError(message)) {
        return canSwitchToCloud
            ? 'The on-device coach session is not ready. Open Coach to finish setup, or try cloud coaching instead.'
            : 'The on-device coach session is not ready. Open Coach to finish model setup, then tap Retry.';
      }
      return canSwitchToCloud
          ? 'The on-device model hit a temporary issue. Retry on-device, or try cloud coaching instead.'
          : 'The on-device model hit a temporary issue. Tap Retry to try again.';
    }
    if (message.contains('No active Gemma model')) {
      return canSwitchToCloud
          ? 'The on-device model is not installed. Try cloud coaching, or complete model setup in Settings.'
          : 'The on-device model is not installed. Complete model setup, then try again.';
    }
    if (message.toLowerCase().contains('empty response')) {
      return 'The coach returned no text. Tap Retry to try again.';
    }
    return canSwitchToCloud
        ? 'On-device coaching is temporarily unavailable. Retry on-device, or try cloud coaching instead.'
        : 'On-device coaching is temporarily unavailable. Tap Retry or ask again in a moment.';
  }

  static bool _isChatInitError(String message) {
    final lower = message.toLowerCase();
    return lower.contains('chat not initialized');
  }

  static bool _isCloudError(String message) {
    final lower = message.toLowerCase();
    return lower.contains('openrouter') ||
        lower.contains('cloud llm') ||
        lower.contains('dioexception') ||
        lower.contains('cloud coach');
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
