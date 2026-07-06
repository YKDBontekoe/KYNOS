import 'package:kynos/domain/utils/gemma_device_capability.dart';
import 'package:kynos/infrastructure/ai/gemma/gemma_device_ram_probe.dart';
import 'package:kynos/infrastructure/ai/gemma/gemma_thermal_probe.dart';

/// Resolves the current on-device Gemma tier from platform RAM and thermal probes.
abstract final class GemmaRuntimeTier {
  static Future<GemmaInferenceTier> resolve({
    bool? isThermallyThrottled,
  }) async {
    final ram = await GemmaDeviceRamProbe.totalRamBytes();
    final throttled =
        isThermallyThrottled ?? await GemmaThermalProbe.isThermallyThrottled();
    return GemmaDeviceCapabilitySelector.select(
      totalRamBytes: ram,
      isThermallyThrottled: throttled,
    );
  }
}
