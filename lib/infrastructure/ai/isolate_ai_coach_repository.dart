import 'dart:async';
import 'dart:isolate';

import 'package:flutter/services.dart';
import 'package:kynos/domain/entities/ai_inference_backend.dart';
import 'package:kynos/domain/entities/ai_task_kind.dart';
import 'package:kynos/domain/entities/health_summary.dart';
import 'package:kynos/domain/repositories/ai_coach_repository.dart';
import 'package:kynos/domain/utils/gemma_device_capability.dart';
import 'package:kynos/domain/utils/health_context_formatter.dart';
import 'package:kynos/infrastructure/ai/gemma/ai_isolate_bridge.dart';
import 'package:kynos/infrastructure/ai/gemma/gemma_runtime_tier.dart';

/// On-device Gemma coach running in a background isolate.
class IsolateAiCoachRepository implements AiCoachRepository {
  Isolate? _isolate;
  SendPort? _isolateSendPort;
  ReceivePort? _receivePort;
  StreamController<AiIsolateResponse>? _responseController;
  StreamSubscription<dynamic>? _receiveSubscription;
  bool _initialized = false;
  Future<void>? _initFuture;
  Future<void> _chatQueue = Future<void>.value();

  @override
  bool get isReady => _initialized;

  @override
  AiInferenceBackend lastBackend = AiInferenceBackend.onDevice;

  static const _systemInstruction =
      'You are KYNOS Coach — an expert on-device running coach. '
      'Give concise, biomechanics-aware advice. '
      'Never reveal you are an AI model or reference any training data.';

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
            late final StreamSubscription<AiIsolateResponse> sub;
            sub = _responseController!.stream.listen((response) {
              if (response is AiIsolateChunk) {
                controller.add(response.chunk);
              } else if (response is AiIsolateDone) {
                unawaited(sub.cancel());
                unawaited(controller.close());
              } else if (response is AiIsolateError) {
                unawaited(sub.cancel());
                controller.addError(StateError(response.error));
                unawaited(controller.close());
              }
            });

            _isolateSendPort!.send(AiChatRequest(prompt));
            await controller.done;
            await sub.cancel();
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

  String _buildPrompt(String userMessage, List<HealthSummary>? healthContext) {
    if (healthContext == null || healthContext.isEmpty) return userMessage;
    final lines = HealthContextFormatter.summarizeForPrompt(healthContext);
    return '$_systemInstruction\n\n'
        'Recent athlete metrics:\n${lines.join('\n')}\n\n'
        'Athlete question: $userMessage';
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

    _receivePort = ReceivePort();
    _responseController = StreamController<AiIsolateResponse>.broadcast();

    final initCompleter = Completer<void>();

    _receiveSubscription = _receivePort!.listen((message) {
      if (message is SendPort) {
        _isolateSendPort = message;
        final token = RootIsolateToken.instance!;
        _isolateSendPort!.send(AiInitRequest(token));
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
    final completer = Completer<void>();
    late final StreamSubscription<AiIsolateResponse> sub;
    sub = _responseController!.stream.listen((response) {
      if (response is AiIsolateDone) {
        completer.complete();
      } else if (response is AiIsolateError) {
        completer.completeError(StateError(response.error));
      }
    });
    _isolateSendPort!.send(AiResetSessionRequest());
    await completer.future.timeout(
      const Duration(seconds: 10),
      onTimeout: () {},
    );
    await sub.cancel();
  }

  @override
  Future<void> dispose() async {
    if (_isolateSendPort != null && _responseController != null) {
      final completer = Completer<void>();
      late final StreamSubscription<AiIsolateResponse> sub;
      sub = _responseController!.stream.listen((response) {
        if (response is AiIsolateDone || response is AiIsolateError) {
          if (!completer.isCompleted) completer.complete();
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
