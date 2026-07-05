import 'package:flutter_test/flutter_test.dart';
import 'package:kynos/domain/entities/openrouter_model.dart';
import 'package:kynos/domain/utils/acwr.dart';
import 'package:kynos/domain/utils/gemma_device_capability.dart';

void main() {
  group('GemmaDeviceCapabilitySelector', () {
    test('disables LLM below 4 GB RAM', () {
      expect(
        GemmaDeviceCapabilitySelector.tierForDeviceRam(3 * 1024 * 1024 * 1024),
        GemmaInferenceTier.disabled,
      );
    });

    test('uses constrained tier between 4 and 6 GB', () {
      expect(
        GemmaDeviceCapabilitySelector.tierForDeviceRam(5 * 1024 * 1024 * 1024),
        GemmaInferenceTier.constrained,
      );
    });

    test('uses full tier at 6 GB+', () {
      expect(
        GemmaDeviceCapabilitySelector.tierForDeviceRam(8 * 1024 * 1024 * 1024),
        GemmaInferenceTier.full,
      );
    });
  });

  group('isFreeOpenRouterModel', () {
    test('returns true when input and output are zero', () {
      const model = OpenRouterModel(
        id: 'test/free',
        name: 'Free Model',
        contextLength: 8192,
        pricing: OpenRouterModelPricing(prompt: '0', completion: '0'),
      );
      expect(isFreeOpenRouterModel(model), isTrue);
      expect(formatOpenRouterPricing(model), 'Free');
    });

    test('returns false when output is paid', () {
      const model = OpenRouterModel(
        id: 'test/partial',
        name: 'Partial',
        contextLength: 8192,
        pricing: OpenRouterModelPricing(prompt: '0', completion: '0.000001'),
      );
      expect(isFreeOpenRouterModel(model), isFalse);
    });
  });

  group('computeAcwr', () {
    test('returns null with insufficient history', () {
      expect(computeAcwr(const []), isNull);
    });
  });
}
