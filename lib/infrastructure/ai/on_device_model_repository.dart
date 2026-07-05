import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:kynos/domain/repositories/ai_model_repository.dart';
import 'package:kynos/domain/utils/gemma_device_capability.dart';
import 'package:kynos/infrastructure/ai/gemma/gemma_device_ram_probe.dart';

/// flutter_gemma implementation of [AiModelRepository].
class OnDeviceModelRepository implements AiModelRepository {
  GemmaInferenceTier? _cachedTier;

  @override
  bool get hasActiveModel => FlutterGemma.hasActiveModel();

  @override
  Future<void> initialize() => FlutterGemma.initialize();

  @override
  Future<void> installFromNetwork({required String url, String? token}) async {
    final ram = await GemmaDeviceRamProbe.totalRamBytes();
    _cachedTier = GemmaDeviceCapabilitySelector.select(
      totalRamBytes: ram,
      isThermallyThrottled: false,
    );

    if (!GemmaDeviceCapabilitySelector.canRunOnDeviceLlm(_cachedTier!)) {
      return;
    }

    await FlutterGemma.installModel(modelType: ModelType.gemmaIt)
        .fromNetwork(url, token: token)
        .install();
  }

  GemmaInferenceTier get inferenceTier =>
      _cachedTier ?? GemmaInferenceTier.full;
}
