import 'package:kynos/domain/utils/gemma_device_capability.dart';
import 'package:kynos/infrastructure/ai/gemma/gemma_device_ram_probe.dart';

/// Resolves the current on-device Gemma tier from platform RAM probes.
abstract final class GemmaRuntimeTier {
  static Future<GemmaInferenceTier> resolve({
    bool isThermallyThrottled = false,
  }) async {
    final ram = await GemmaDeviceRamProbe.totalRamBytes();
    return GemmaDeviceCapabilitySelector.select(
      totalRamBytes: ram,
      isThermallyThrottled: isThermallyThrottled,
    );
  }
}
