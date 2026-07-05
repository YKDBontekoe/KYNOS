import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:kynos/domain/repositories/ai_model_repository.dart';
import 'package:kynos/domain/utils/gemma_device_capability.dart';
import 'package:kynos/infrastructure/ai/gemma/gemma_runtime.dart';
import 'package:kynos/infrastructure/ai/gemma/gemma_runtime_tier.dart';

/// flutter_gemma implementation of [AiModelRepository].
class OnDeviceModelRepository implements AiModelRepository {
  GemmaInferenceTier? _cachedTier;

  @override
  bool get hasActiveModel => FlutterGemma.hasActiveModel();

  @override
  Future<void> initialize({String? huggingFaceToken}) =>
      GemmaRuntime.initialize(huggingFaceToken: huggingFaceToken);

  @override
  Future<void> installFromNetwork({required String url, String? token}) async {
    _cachedTier = await GemmaRuntimeTier.resolve();

    if (!GemmaDeviceCapabilitySelector.canRunOnDeviceLlm(_cachedTier!)) {
      throw StateError(
        'This device cannot run the on-device Gemma model (insufficient RAM).',
      );
    }

    await GemmaRuntime.installGemma4E2B()
        .fromNetwork(url, token: token)
        .install();

    if (!hasActiveModel) {
      throw StateError('Gemma model install completed but model is not active.');
    }
  }

  GemmaInferenceTier get inferenceTier =>
      _cachedTier ?? GemmaInferenceTier.full;
}
