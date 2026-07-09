import 'package:flutter_test/flutter_test.dart';
import 'package:kynos/domain/catalog/on_device_model_catalog.dart';
import 'package:kynos/domain/entities/on_device_model.dart';

void main() {
  group('OnDeviceModelCatalog', () {
    test('resolves known model ids', () {
      expect(
        OnDeviceModelCatalog.byId('qwen3-0.6b').name,
        'Qwen3 0.6B',
      );
      expect(
        OnDeviceModelCatalog.byId('functiongemma-270m').name,
        'FunctionGemma 270M',
      );
      expect(
        OnDeviceModelCatalog.byId('qwen2.5-1.5b').name,
        'Qwen 2.5 1.5B',
      );
      expect(
        OnDeviceModelCatalog.byId('gemma4-e4b').name,
        'Gemma 4 E4B',
      );
      expect(
        OnDeviceModelCatalog.byId('unknown').id,
        OnDeviceModelCatalog.defaultModelId,
      );
    });

    test('filters lightweight models on low-RAM devices', () {
      final models = OnDeviceModelCatalog.forDevice(
        isWeb: false,
        totalRamBytes: 4 * 1024 * 1024 * 1024,
      );

      expect(models.map((m) => m.id), contains('gemma3-270m'));
      expect(models.map((m) => m.id), contains('functiongemma-270m'));
      expect(models.map((m) => m.id), isNot(contains('gemma4-e2b')));
      expect(models.map((m) => m.id), isNot(contains('gemma4-e4b')));
      expect(models.map((m) => m.id), isNot(contains('phi-4-mini')));
    });

    test('includes flagship models on high-RAM mobile', () {
      final models = OnDeviceModelCatalog.forDevice(
        isWeb: false,
        totalRamBytes: 8 * 1024 * 1024 * 1024,
      );

      expect(models.map((m) => m.id), contains('gemma4-e2b'));
      expect(models.map((m) => m.id), contains('gemma4-e4b'));
      expect(models.map((m) => m.id), contains('qwen3-0.6b'));
      expect(models.map((m) => m.id), contains('phi-4-mini'));
    });

    test('limits web catalog to litert-lm bundles', () {
      final models = OnDeviceModelCatalog.forDevice(
        isWeb: true,
        totalRamBytes: 8 * 1024 * 1024 * 1024,
      );

      final ids = models.map((m) => m.id).toList();
      expect(ids, isNot(contains('gemma3-270m')));
      expect(ids, isNot(contains('gemma3-1b')));
      expect(ids, isNot(contains('qwen2.5-1.5b')));
      expect(ids, contains('qwen3-0.6b'));
      expect(ids, contains('gemma4-e4b'));
      expect(ids, contains('gemma3n-e2b'));
    });

    test('exposes every capability on at least one model', () {
      final allCapabilities = OnDeviceModelCatalog.models
          .expand((model) => model.capabilities)
          .toSet();

      expect(
        allCapabilities,
        containsAll(OnDeviceModelCapability.values),
      );
    });

    test('groups models by tier and filters by capability', () {
      final grouped = OnDeviceModelCatalog.modelsGroupedByTier(
        isWeb: false,
        totalRamBytes: 8 * 1024 * 1024 * 1024,
        requiredCapabilities: {OnDeviceModelCapability.thinkingMode},
      );

      final thinkingModels =
          grouped.values.expand((models) => models).toList();

      expect(thinkingModels, isNotEmpty);
      expect(
        thinkingModels.every(
          (model) => model.hasCapability(OnDeviceModelCapability.thinkingMode),
        ),
        isTrue,
      );
      expect(
        thinkingModels.map((model) => model.id),
        isNot(contains('gemma3-1b')),
      );
    });
  });
}
