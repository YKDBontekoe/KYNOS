import 'package:kynos/domain/utils/gemma_device_capability.dart';

/// Token budgets keyed by on-device Gemma inference tier.
abstract final class GemmaInferenceLimits {
  static int maxContextTokens(GemmaInferenceTier tier) => switch (tier) {
        GemmaInferenceTier.full => 1024,
        GemmaInferenceTier.constrained => 512,
        GemmaInferenceTier.disabled => 0,
      };

  static int maxOutputTokens(GemmaInferenceTier tier) => switch (tier) {
        GemmaInferenceTier.full => 256,
        GemmaInferenceTier.constrained => 128,
        GemmaInferenceTier.disabled => 0,
      };

  /// Hard ceiling for user prompt characters before isolate submission.
  static const int maxPromptCharacters = 2048;
}
