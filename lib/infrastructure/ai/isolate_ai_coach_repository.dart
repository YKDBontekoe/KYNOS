import 'dart:async';
import 'dart:isolate';

import 'package:flutter/services.dart';
import 'package:kynos/domain/entities/ai_inference_backend.dart';
import 'package:kynos/domain/entities/ai_task_kind.dart';
import 'package:kynos/domain/entities/health_summary.dart';
import 'package:kynos/domain/repositories/ai_coach_repository.dart';
import 'package:kynos/domain/utils/ai_inference_error_policy.dart';
import 'package:kynos/domain/utils/gemma_device_capability.dart';
import 'package:kynos/domain/utils/gemma_inference_limits.dart';
import 'package:kynos/infrastructure/ai/gemma/ai_isolate_bridge.dart';
import 'package:kynos/infrastructure/ai/gemma/coach_prompt_builder.dart';
import 'package:kynos/infrastructure/ai/gemma/gemma_runtime_tier.dart';
import 'package:kynos/infrastructure/ai/secure_api_key_storage.dart';
import 'package:logger/logger.dart';

/// On-device Gemma coach running in a background isolate.
class IsolateAiCoachRepository implements AiCoachRepository {
  IsolateAiCoachRepository({SecureApiKeyStorage? keyStorage})
      : _keyStorage = keyStorage ?? SecureApiKeyStorage();

  final SecureApiKeyStorage _keyStorage;
  final _logger = Logger();
  Isolate? _isolate;
  SendPort? _isolateSendPort;
  ReceivePort? _receivePort;
  StreamController<AiIsolateResponse>? _responseController;
  StreamSubscription<dynamic>? _receiveSubscription;
  bool _initialized = false;
  Future<void>? _initFuture;
  Future<void> _chatQueue = Future<void>.value();
  int _nextRequestId = 1;

  @override
  bool get isReady => _initialized;

  @override
  AiInferenceBackend lastBackend = AiInferenceBackend.onDevice;

  @override
  Stream<AiChunk> chat({
    required String userMessage,
    List<HealthSummary>? healthContext,
    AiTaskKind taskKind = AiTaskKind.coachChat,
    int estimatedPromptTokens = 0,
  }) {
    final completer = Completer<void>();
    final previous = _chatQueue;
    _chatQueue = previous.then((_) => completer.future);

    final controller = StreamController<AiChunk>();

    previous
        .then((_) async {
          try {
            final tier = await GemmaRuntimeTier.resolve();
            if (!GemmaDeviceCapabilitySelector.canRunOnDeviceLlm(tier)) {
              lastBackend = AiInferenceBackend.rulesOnly;
              controller.add(
                'On-device model unavailable on this device. '
                'Enable Advanced cloud tasks in Settings with an OpenRouter key.',
              );
              await controller.close();
              return;
            }

            await _ensureIsolate();
            lastBackend = AiInferenceBackend.onDevice;

            final prompt = _buildPrompt(userMessage, healthContext);
            await _chatWithRecovery(prompt: prompt, controller: controller);
          } catch (error, stackTrace) {
            if (!controller.isClosed) {
              controller.addError(error, stackTrace);
              await controller.close();
            }
          } finally {
            completer.complete();
          }
        })
        .catchError((Object error, StackTrace stackTrace) {
          if (!controller.isClosed) {
            controller.addError(error, stackTrace);
            controller.close();
          }
          completer.complete();
        });

    return controller.stream;
  }

  Future<void> _chatWithRecovery({
    required String prompt,
    required StreamController<AiChunk> controller,
  }) async {
    Object? lastError;
    StackTrace? lastStackTrace;

    for (var attempt = 0; attempt < AiChatRecoveryPlan.maxAttempts; attempt++) {
      try {
        final chunks = await _runSingleChatAttempt(prompt);
        for (final chunk in chunks) {
          if (!controller.isClosed) controller.add(chunk);
        }
        if (!controller.isClosed) await controller.close();
        return;
      } catch (error, stackTrace) {
        lastError = error;
        lastStackTrace = stackTrace;
        _logger.w(
          'On-device chat attempt ${attempt + 1} failed',
          error: error,
          stackTrace: stackTrace,
        );

        final canRetry = attempt < AiChatRecoveryPlan.maxAttempts - 1 &&
            AiInferenceErrorPolicy.isRecoverable(error);
        if (!canRetry) break;

        final action = AiChatRecoveryPlan.actionBeforeRetry(attempt);
        try {
          await _applyRecoveryAction(action);
        } catch (recoveryError, recoveryStack) {
          _logger.w(
            'Recovery action $action failed',
            error: recoveryError,
            stackTrace: recoveryStack,
          );
          if (action == AiChatRecoveryAction.respawnIsolate) {
            break;
          }
        }
      }
    }

    if (!controller.isClosed) {
      controller.addError(lastError ?? StateError('Unknown inference error'), lastStackTrace);
      await controller.close();
    }
  }

  Future<List<AiChunk>> _runSingleChatAttempt(String prompt) async {
    final requestId = _nextRequestId++;
    final buffer = <AiChunk>[];
    final completer = Completer<void>();

    late final StreamSubscription<AiIsolateResponse> sub;
    sub = _responseController!.stream.listen((response) {
      if (response is AiIsolateChunk && response.requestId == requestId) {
        buffer.add(response.chunk);
      } else if (response is AiIsolateDone && response.requestId == requestId) {
        if (!completer.isCompleted) completer.complete();
      } else if (response is AiIsolateError && response.requestId == requestId) {
        if (!completer.isCompleted) {
          completer.completeError(StateError(response.error));
        }
      }
    });

    _isolateSendPort!.send(AiChatRequest(prompt, requestId: requestId));

    try {
      await completer.future.timeout(const Duration(seconds: 120));
      return buffer;
    } finally {
      await sub.cancel();
    }
  }

  Future<void> _applyRecoveryAction(AiChatRecoveryAction action) async {
    switch (action) {
      case AiChatRecoveryAction.reloadChat:
        await _sendControlRequest(AiReloadChatRequest(requestId: _nextRequestId++));
      case AiChatRecoveryAction.reloadModelCpu:
        await _sendControlRequest(
          AiReloadModelRequest(
            backend: AiPreferredBackend.cpu,
            requestId: _nextRequestId++,
          ),
        );
      case AiChatRecoveryAction.respawnIsolate:
        await _tearDownIsolate();
        await _ensureIsolate();
      case AiChatRecoveryAction.none:
        return;
    }
  }

  Future<void> _sendControlRequest(AiIsolateRequest request) async {
    final requestId = switch (request) {
      AiReloadChatRequest(:final requestId) => requestId,
      AiReloadModelRequest(:final requestId) => requestId,
      AiResetSessionRequest(:final requestId) => requestId,
      _ => 0,
    };

    final completer = Completer<void>();
    late final StreamSubscription<AiIsolateResponse> sub;
    sub = _responseController!.stream.listen((response) {
      if (response is AiIsolateDone && response.requestId == requestId) {
        if (!completer.isCompleted) completer.complete();
      } else if (response is AiIsolateError && response.requestId == requestId) {
        if (!completer.isCompleted) {
          completer.completeError(StateError(response.error));
        }
      }
    });

    _isolateSendPort!.send(request);

    try {
      await completer.future.timeout(const Duration(seconds: 30));
    } finally {
      await sub.cancel();
    }
  }

  String _buildPrompt(String userMessage, List<HealthSummary>? healthContext) {
    final prompt = buildCoachUserMessage(userMessage, healthContext);
    if (prompt.length <= GemmaInferenceLimits.maxPromptCharacters) {
      return prompt;
    }
    return prompt.substring(0, GemmaInferenceLimits.maxPromptCharacters);
  }

  Future<void> _ensureIsolate() async {
    if (_isolateSendPort != null && _initialized) return;
    if (_initFuture != null) {
      await _initFuture;
      return;
    }

    _initFuture = _spawnIsolate();
    try {
      await _initFuture;
    } finally {
      _initFuture = null;
    }
  }

  Future<void> _spawnIsolate() async {
    await _tearDownIsolate();

    final hfToken = await _keyStorage.readHuggingFaceToken();

    _receivePort = ReceivePort();
    _responseController = StreamController<AiIsolateResponse>.broadcast();

    final initCompleter = Completer<void>();

    _receiveSubscription = _receivePort!.listen((message) {
      if (message is SendPort) {
        _isolateSendPort = message;
        final token = RootIsolateToken.instance!;
        _isolateSendPort!.send(
          AiInitRequest(token, huggingFaceToken: hfToken),
        );
      } else if (message is AiIsolateResponse) {
        _responseController?.add(message);
        if (message is AiIsolateReady) {
          _initialized = true;
          if (!initCompleter.isCompleted) initCompleter.complete();
        } else if (message is AiIsolateError && !_initialized) {
          if (!initCompleter.isCompleted) {
            initCompleter.completeError(StateError(message.error));
          }
        }
      }
    });

    try {
      _isolate = await Isolate.spawn(
        aiIsolateEntrypoint,
        _receivePort!.sendPort,
        debugName: 'kynos-ai-isolate',
      );

      await initCompleter.future.timeout(
        const Duration(seconds: 60),
        onTimeout: () => throw TimeoutException('AI isolate init timed out'),
      );
    } catch (error) {
      await _tearDownIsolate();
      rethrow;
    }
  }

  Future<void> _tearDownIsolate() async {
    _initialized = false;
    _isolateSendPort = null;
    await _receiveSubscription?.cancel();
    _receiveSubscription = null;
    await _responseController?.close();
    _responseController = null;
    _isolate?.kill(priority: Isolate.immediate);
    _isolate = null;
    _receivePort?.close();
    _receivePort = null;
  }

  @override
  Future<void> resetSession() async {
    if (_isolateSendPort == null) return;
    try {
      await _sendControlRequest(AiResetSessionRequest(requestId: _nextRequestId++));
    } on Object catch (error, stackTrace) {
      _logger.w('resetSession failed', error: error, stackTrace: stackTrace);
    }
  }

  @override
  Future<void> dispose() async {
    _chatQueue = Future<void>.value();
    if (_isolateSendPort != null && _responseController != null) {
      const disposeRequestId = 0;
      final completer = Completer<void>();
      late final StreamSubscription<AiIsolateResponse> sub;
      sub = _responseController!.stream.listen((response) {
        final matchesDispose = switch (response) {
          AiIsolateDone(:final requestId) => requestId == disposeRequestId,
          AiIsolateError(:final requestId) => requestId == disposeRequestId,
          _ => false,
        };
        if (matchesDispose && !completer.isCompleted) {
          completer.complete();
        }
      });
      _isolateSendPort!.send(AiDisposeRequest());
      await completer.future.timeout(
        const Duration(seconds: 5),
        onTimeout: () {},
      );
      await sub.cancel();
    }
    await _tearDownIsolate();
  }
}
