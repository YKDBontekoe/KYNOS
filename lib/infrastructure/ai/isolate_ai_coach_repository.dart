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
import 'package:kynos/infrastructure/ai/gemma/gemma_device_ram_probe.dart';

/// On-device Gemma coach running in a background isolate.
class IsolateAiCoachRepository implements AiCoachRepository {
  Isolate? _isolate;
  SendPort? _isolateSendPort;
  StreamController<AiIsolateResponse>? _responseController;
  bool _initialized = false;

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
  }) async* {
    final ram = await GemmaDeviceRamProbe.totalRamBytes();
    final tier = GemmaDeviceCapabilitySelector.select(
      totalRamBytes: ram,
      isThermallyThrottled: false,
    );
    if (!GemmaDeviceCapabilitySelector.canRunOnDeviceLlm(tier)) {
      lastBackend = AiInferenceBackend.rulesOnly;
      yield 'On-device model unavailable on this device. '
          'Enable Advanced cloud tasks in Settings with an OpenRouter key.';
      return;
    }

    await _ensureIsolate();
    lastBackend = AiInferenceBackend.onDevice;

    final prompt = _buildPrompt(userMessage, healthContext);
    final chunkController = StreamController<AiChunk>();
    late final StreamSubscription<AiIsolateResponse> sub;

    sub = _responseController!.stream.listen((response) {
      if (response is AiIsolateChunk) {
        chunkController.add(response.chunk);
      } else if (response is AiIsolateDone) {
        unawaited(sub.cancel());
        unawaited(chunkController.close());
      } else if (response is AiIsolateError) {
        unawaited(sub.cancel());
        chunkController.addError(StateError(response.error));
        unawaited(chunkController.close());
      }
    });

    _isolateSendPort!.send(AiChatRequest(prompt));
    yield* chunkController.stream;
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

    final receivePort = ReceivePort();
    _responseController = StreamController<AiIsolateResponse>.broadcast();

    _isolate = await Isolate.spawn(
      aiIsolateEntrypoint,
      receivePort.sendPort,
    );

    final completer = Completer<void>();
    receivePort.listen((message) {
      if (message is SendPort) {
        _isolateSendPort = message;
        final token = RootIsolateToken.instance!;
        _isolateSendPort!.send(AiInitRequest(token));
      } else if (message is AiIsolateResponse) {
        _responseController?.add(message);
        if (message is AiIsolateReady) {
          _initialized = true;
          if (!completer.isCompleted) completer.complete();
        } else if (message is AiIsolateError && !_initialized) {
          if (!completer.isCompleted) {
            completer.completeError(StateError(message.error));
          }
        }
      }
    });

    await completer.future.timeout(const Duration(seconds: 60));
  }

  @override
  Future<void> resetSession() async {
    _isolateSendPort?.send(AiResetSessionRequest());
  }

  @override
  Future<void> dispose() async {
    _isolateSendPort?.send(AiDisposeRequest());
    _isolate?.kill(priority: Isolate.immediate);
    _isolate = null;
    _isolateSendPort = null;
    _initialized = false;
    await _responseController?.close();
    _responseController = null;
  }
}
