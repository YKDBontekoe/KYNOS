import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:flutter_gemma_litertlm/flutter_gemma_litertlm.dart';
import 'package:kynos/domain/catalog/on_device_model_catalog.dart';
import 'package:kynos/domain/entities/on_device_model.dart';
import 'package:kynos/infrastructure/ai/gemma/on_device_model_installer.dart';

/// Central bootstrap for flutter_gemma 1.x opt-in inference engines.
///
/// Core ships no engine by default — [LiteRtLmEngine] must be registered before
/// [FlutterGemma.getActiveModel] or model installation can run.
abstract final class GemmaRuntime {
  static const _inferenceEngines = [LiteRtLmEngine()];

  /// Cache API storage works in browsers without OPFS support. Streaming mode
  /// requires OPFS and prevents the entire Flutter app from starting there.
  static const _webStorageMode = WebStorageMode.cacheApi;

  static String? _installedCatalogId;

  static String? get installedCatalogId => _installedCatalogId;

  static Future<void> initialize({String? huggingFaceToken}) async {
    await FlutterGemma.initialize(
      inferenceEngines: _inferenceEngines,
      webStorageMode: _webStorageMode,
      huggingFaceToken: huggingFaceToken != null && huggingFaceToken.isNotEmpty
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
    final spec = FlutterGemmaPlugin.instance.modelManager.activeInferenceModel;
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
    _installedCatalogId = null;
  }

  /// Starts installing an on-device model (.litertlm).
  static InferenceInstallationBuilder installModel(OnDeviceModel model) =>
      OnDeviceModelInstaller.builderFor(model);

  static String downloadUrlFor(OnDeviceModel model) =>
      model.downloadUrl(isWeb: kIsWeb);

  /// Legacy Gemma 4 install entry point.
  static InferenceInstallationBuilder installGemma4E2B() =>
      installModel(OnDeviceModelCatalog.gemma4E2b);

  /// Legacy default download URL.
  static String get modelDownloadUrl =>
      downloadUrlFor(OnDeviceModelCatalog.gemma4E2b);

  static void markInstalled(String catalogId) =>
      _installedCatalogId = catalogId;
}
