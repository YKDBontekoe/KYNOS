import 'dart:async';
import 'dart:isolate';

import 'package:kynos/domain/entities/health_summary.dart';
import 'package:kynos/domain/repositories/ai_coach_repository.dart';

/// Stub implementation of [AiCoachRepository] using Gemma 4 E2B via LiteRT-LM.
///
/// Full implementation will:
///  1. Spawn a [BackgroundIsolateBinaryMessenger]-capable [Isolate].
///  2. Load the model from [assets/models/] using the LiteRT-LM C++ runtime.
///  3. Expose a [SendPort] for request/response message passing.
///  4. Stream decoded tokens back to the UI via a [StreamController].
///
/// See: docs/architecture/ai_isolate_design.md
class GemmaCoachRepository implements AiCoachRepository {
  GemmaCoachRepository._();

  static final GemmaCoachRepository instance = GemmaCoachRepository._();

  bool _ready = false;

  @override
  bool get isReady => _ready;

  @override
  Stream<AiChunk> chat({
    required String userMessage,
    List<HealthSummary>? healthContext,
  }) async* {
    // TODO(ai): Replace with actual LiteRT-LM isolate bridge.
    await Future<void>.delayed(const Duration(milliseconds: 200));
    yield 'Nexus Coach AI (Gemma 4 E2B) — model not yet loaded. ';
    yield 'Integrate LiteRT-LM runtime to enable on-device inference.';
  }

  @override
  Future<void> dispose() async {
    _ready = false;
    // TODO(ai): Terminate background isolate and release model memory.
  }
}
