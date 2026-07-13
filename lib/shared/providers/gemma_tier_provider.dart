import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kynos/domain/utils/gemma_device_capability.dart';
import 'package:kynos/infrastructure/ai/gemma/gemma_runtime_tier.dart';

/// Resolves the current on-device Gemma inference tier for UI routing decisions.
final gemmaInferenceTierProvider = FutureProvider<GemmaInferenceTier>((ref) {
  return GemmaRuntimeTier.resolve();
});
