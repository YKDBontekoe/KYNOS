import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:kynos/domain/catalog/on_device_model_catalog.dart';
import 'package:kynos/domain/entities/on_device_model.dart';
import 'package:kynos/domain/repositories/ai_model_repository.dart';
import 'package:kynos/domain/utils/gemma_device_capability.dart';
import 'package:kynos/infrastructure/ai/gemma/gemma_device_ram_probe.dart';
import 'package:kynos/infrastructure/ai/gemma/gemma_runtime.dart';
import 'package:kynos/infrastructure/ai/gemma/gemma_runtime_tier.dart';

/// flutter_gemma implementation of [AiModelRepository].
class OnDeviceModelRepository implements AiModelRepository {
  GemmaInferenceTier? _cachedTier;
  String? _installedModelId;

  @override
  bool get hasActiveModel => GemmaRuntime.hasCompatibleActiveModel();

  @override
  String? get installedModelId =>
      _installedModelId ?? GemmaRuntime.installedCatalogId;

  @override
  bool isActiveModel(String catalogId) =>
      hasActiveModel && installedModelId == catalogId;

  @override
  Future<void> initialize({String? huggingFaceToken}) =>
      GemmaRuntime.initialize(huggingFaceToken: huggingFaceToken);

  @override
  Future<void> install(OnDeviceModel model, {String? token}) async {
    _cachedTier = await GemmaRuntimeTier.resolve();

    if (!GemmaDeviceCapabilitySelector.canRunOnDeviceLlm(_cachedTier!)) {
      throw StateError(
        'This device cannot run on-device models (insufficient RAM).',
      );
    }

    final ramBytes = await GemmaDeviceRamProbe.totalRamBytes();
    if (ramBytes != null) {
      final ramGb = ramBytes / (1024 * 1024 * 1024);
      if (ramGb < model.minRamGb) {
        throw StateError(
          'This device does not have enough RAM for ${model.name}. '
          'Try a lighter model such as ${OnDeviceModelCatalog.gemma3_270m.name}.',
        );
      }
    }

    if (model.requiresHuggingFaceToken && (token == null || token.isEmpty)) {
      throw StateError(
        'A HuggingFace access token is required for ${model.name}.',
      );
    }

    final url = model.downloadUrl(isWeb: kIsWeb);
    await GemmaRuntime.installModel(model)
        .fromNetwork(url, token: token)
        .install();

    if (!hasActiveModel) {
      throw StateError(
        '${model.name} install completed but model is not active.',
      );
    }

    _installedModelId = model.id;
    GemmaRuntime.markInstalled(model.id);
  }

  GemmaInferenceTier get inferenceTier =>
      _cachedTier ?? GemmaInferenceTier.full;
}
