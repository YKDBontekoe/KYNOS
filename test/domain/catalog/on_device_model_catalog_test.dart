import 'package:flutter_test/flutter_test.dart';
import 'package:kynos/domain/catalog/on_device_model_catalog.dart';

void main() {
  group('OnDeviceModelCatalog', () {
    test('resolves known model ids', () {
      expect(
        OnDeviceModelCatalog.byId('qwen3-0.6b').name,
        'Qwen3 0.6B',
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
      expect(models.map((m) => m.id), isNot(contains('gemma4-e2b'));
    });

    test('includes gemma4 on high-RAM mobile', () {
      final models = OnDeviceModelCatalog.forDevice(
        isWeb: false,
        totalRamBytes: 8 * 1024 * 1024 * 1024,
      );

      expect(models.map((m) => m.id), contains('gemma4-e2b'));
      expect(models.map((m) => m.id), contains('qwen3-0.6b'));
    });

    test('limits web catalog to litert-lm bundles', () {
      final models = OnDeviceModelCatalog.forDevice(
        isWeb: true,
        totalRamBytes: 8 * 1024 * 1024 * 1024,
      );

      expect(models.map((m) => m.id), isNot(contains('gemma3-270m')));
      expect(models.map((m) => m.id), contains('qwen3-0.6b'));
    });
  });
}
