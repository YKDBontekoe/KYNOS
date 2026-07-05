import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:flutter_gemma_litertlm/flutter_gemma_litertlm.dart';
import 'package:kynos/core/constants/app_constants.dart';

/// Central bootstrap for flutter_gemma 1.x opt-in inference engines.
///
/// Core ships no engine by default — [LiteRtLmEngine] must be registered before
/// [FlutterGemma.getActiveModel] or model installation can run.
abstract final class GemmaRuntime {
  static const _inferenceEngines = [LiteRtLmEngine()];

  static Future<void> initialize({String? huggingFaceToken}) async {
    await FlutterGemma.initialize(
      inferenceEngines: _inferenceEngines,
      webStorageMode: WebStorageMode.streaming,
      huggingFaceToken:
          huggingFaceToken != null && huggingFaceToken.isNotEmpty
              ? huggingFaceToken
              : null,
    );
    await evictLegacyModelsIfNeeded();
  }

  /// Whether the persisted active model can run on the registered engines.
  ///
  /// Older app builds installed MediaPipe `.task` models. [LiteRtLmEngine]
  /// only handles [ModelFileType.litertlm], so a stale `.task` identity must
  /// be cleared and the Gemma 4 `.litertlm` bundle reinstalled.
  static bool hasCompatibleActiveModel() {
    if (!FlutterGemma.hasActiveModel()) return false;
    final spec =
        FlutterGemmaPlugin.instance.modelManager.activeInferenceModel;
    if (spec is! InferenceModelSpec) return false;
    return spec.fileType == ModelFileType.litertlm;
  }

  /// Removes legacy `.task` installs and clears incompatible active identities.
  static Future<void> evictLegacyModelsIfNeeded() async {
    if (hasCompatibleActiveModel()) return;

    final installed = await FlutterGemma.listInstalledModels();
    for (final modelId in installed) {
      if (!modelId.toLowerCase().endsWith('.task')) continue;
      try {
        await FlutterGemma.uninstallModel(modelId);
      } catch (_) {
        // Best-effort cleanup of partially downloaded legacy models.
      }
    }

    if (FlutterGemma.hasActiveModel()) {
      await FlutterGemma.clearActiveInferenceIdentity();
    }
  }

  /// Starts installing the on-device Gemma 4 E2B model (.litertlm).
  static InferenceInstallationBuilder installGemma4E2B() =>
      FlutterGemma.installModel(
        modelType: ModelType.gemma4,
        fileType: ModelFileType.litertlm,
      );

  /// HuggingFace URL for the active platform.
  static String get modelDownloadUrl {
    if (kIsWeb) {
      return 'https://huggingface.co/litert-community/gemma-4-E2B-it-litert-lm'
          '/resolve/main/gemma-4-E2B-it-web.litertlm?download=true';
    }
    return AppConstants.modelDownloadUrl;
  }
}
