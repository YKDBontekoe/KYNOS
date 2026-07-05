/// On-device Gemma inference tier based on device resources.
enum GemmaInferenceTier {
  /// GPU backend, full coaching and refinements.
  full,

  /// CPU backend with reduced threads — warm device or 4–6 GB RAM.
  constrained,

  /// No LLM — deterministic rules-only insights.
  disabled,
}

/// Selects the best local Gemma 4 runtime profile for this device.
///
/// Pure domain logic — RAM bytes are supplied by infrastructure.
abstract final class GemmaDeviceCapabilitySelector {
  static const gemma4E2bModelId = 'gemma4-e2b-int4';

  /// Four GB threshold — below this, skip on-device LLM entirely.
  static const int minRamBytesForLlm = 4 * 1024 * 1024 * 1024;

  /// Six GB threshold — below this, use constrained CPU inference.
  static const int preferredRamBytesForGpu = 6 * 1024 * 1024 * 1024;

  static GemmaInferenceTier tierForDeviceRam(int? totalRamBytes) {
    if (totalRamBytes == null) return GemmaInferenceTier.full;
    if (totalRamBytes < minRamBytesForLlm) return GemmaInferenceTier.disabled;
    if (totalRamBytes < preferredRamBytesForGpu) {
      return GemmaInferenceTier.constrained;
    }
    return GemmaInferenceTier.full;
  }

  static GemmaInferenceTier tierForThermal({required bool isThermallyThrottled}) {
    if (isThermallyThrottled) return GemmaInferenceTier.constrained;
    return GemmaInferenceTier.full;
  }

  /// Combines RAM and thermal signals — picks the more conservative tier.
  static GemmaInferenceTier select({
    required int? totalRamBytes,
    required bool isThermallyThrottled,
  }) {
    final ramTier = tierForDeviceRam(totalRamBytes);
    final thermalTier = tierForThermal(isThermallyThrottled: isThermallyThrottled);

    if (ramTier == GemmaInferenceTier.disabled ||
        thermalTier == GemmaInferenceTier.disabled) {
      return GemmaInferenceTier.disabled;
    }
    if (ramTier == GemmaInferenceTier.constrained ||
        thermalTier == GemmaInferenceTier.constrained) {
      return GemmaInferenceTier.constrained;
    }
    return GemmaInferenceTier.full;
  }

  static String modelIdForTier(GemmaInferenceTier tier) {
    return switch (tier) {
      GemmaInferenceTier.full || GemmaInferenceTier.constrained => gemma4E2bModelId,
      GemmaInferenceTier.disabled => gemma4E2bModelId,
    };
  }

  static bool canRunOnDeviceLlm(GemmaInferenceTier tier) =>
      tier != GemmaInferenceTier.disabled;
}
