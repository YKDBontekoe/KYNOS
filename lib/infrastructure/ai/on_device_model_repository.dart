import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:kynos/core/errors/failures.dart';
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
  Future<({Failure? failure})> initialize({String? huggingFaceToken}) async {
    try {
      await GemmaRuntime.initialize(huggingFaceToken: huggingFaceToken);
      return (failure: null);
    } on Object catch (error) {
      return (failure: AiModelFailure(error.toString()));
    }
  }

  @override
  Future<({Failure? failure})> install(OnDeviceModel model, {String? token}) async {
    try {
      _cachedTier = await GemmaRuntimeTier.resolve();

      if (!GemmaDeviceCapabilitySelector.canRunOnDeviceLlm(_cachedTier!)) {
        return (
          failure: const AiModelFailure(
            'This device cannot run on-device models (insufficient RAM).',
          ),
        );
      }

      final ramBytes = await GemmaDeviceRamProbe.totalRamBytes();
      if (ramBytes != null) {
        final ramGb = ramBytes / (1024 * 1024 * 1024);
        if (ramGb < model.minRamGb) {
          return (
            failure: AiModelFailure(
              'This device does not have enough RAM for ${model.name}. '
              'Try a lighter model such as ${OnDeviceModelCatalog.gemma3_270m.name}.',
            ),
          );
        }
      }

      if (model.requiresHuggingFaceToken && (token == null || token.isEmpty)) {
        return (
          failure: AiModelFailure(
            'A HuggingFace access token is required for ${model.name}.',
          ),
        );
      }

      final url = model.downloadUrl(isWeb: kIsWeb);
      await GemmaRuntime.installModel(model)
          .fromNetwork(url, token: token)
          .install();

      if (!hasActiveModel) {
        return (
          failure: AiModelFailure(
            '${model.name} install completed but model is not active.',
          ),
        );
      }

      _installedModelId = model.id;
      GemmaRuntime.markInstalled(model.id);
      return (failure: null);
    } on Object catch (error) {
      return (failure: AiModelFailure(error.toString()));
    }
  }

  GemmaInferenceTier get inferenceTier =>
      _cachedTier ?? GemmaInferenceTier.full;
}
