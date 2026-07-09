import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:kynos/domain/entities/on_device_model.dart';

/// Maps domain [OnDeviceModel] specs to flutter_gemma install APIs.
abstract final class OnDeviceModelInstaller {
  static InferenceInstallationBuilder builderFor(OnDeviceModel model) {
    return FlutterGemma.installModel(
      modelType: _modelTypeFor(model.family),
      fileType: ModelFileType.litertlm,
    );
  }

  static ModelType _modelTypeFor(OnDeviceModelFamily family) {
    return switch (family) {
      OnDeviceModelFamily.gemma4 => ModelType.gemma4,
      OnDeviceModelFamily.gemma3 => ModelType.gemmaIt,
      OnDeviceModelFamily.gemma3n => ModelType.gemmaIt,
      OnDeviceModelFamily.qwen3 => ModelType.qwen3,
      OnDeviceModelFamily.qwen2 => ModelType.qwen,
      OnDeviceModelFamily.phi => ModelType.phi,
      OnDeviceModelFamily.functionGemma => ModelType.functionGemma,
    };
  }
}
