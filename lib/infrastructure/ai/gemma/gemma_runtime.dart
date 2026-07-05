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

  static Future<void> initialize({String? huggingFaceToken}) =>
      FlutterGemma.initialize(
        inferenceEngines: _inferenceEngines,
        webStorageMode: WebStorageMode.streaming,
        huggingFaceToken:
            huggingFaceToken != null && huggingFaceToken.isNotEmpty
                ? huggingFaceToken
                : null,
      );

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
