import 'package:kynos/core/constants/app_constants.dart';
import 'package:kynos/domain/entities/on_device_model.dart';

/// Curated catalog of LiteRT-LM models supported by KYNOS on-device coach.
abstract final class OnDeviceModelCatalog {
  static const defaultModelId = 'gemma4-e2b';

  static const gemma4E2b = OnDeviceModel(
    id: 'gemma4-e2b',
    name: 'Gemma 4 E2B',
    description:
        'Best quality on-device coach. Multimodal-capable Gemma 4 tuned for instruction following.',
    family: OnDeviceModelFamily.gemma4,
    sizeMb: 2400,
    minRamGb: 6,
    requiresHuggingFaceToken: true,
    mobileDownloadUrl: AppConstants.modelDownloadUrl,
    webDownloadUrl:
        'https://huggingface.co/litert-community/gemma-4-E2B-it-litert-lm'
        '/resolve/main/gemma-4-E2B-it-web.litertlm?download=true',
  );

  static const gemma3_270m = OnDeviceModel(
    id: 'gemma3-270m',
    name: 'Gemma 3 270M',
    description:
        'Ultra-light Gemma 3 — lowest RAM footprint, ideal for older phones.',
    family: OnDeviceModelFamily.gemma3,
    sizeMb: 300,
    minRamGb: 4,
    requiresHuggingFaceToken: true,
    mobileDownloadUrl:
        'https://huggingface.co/litert-community/gemma-3-270m-it'
        '/resolve/main/gemma3-270m-it-q8.litertlm?download=true',
    webDownloadUrl:
        'https://huggingface.co/litert-community/gemma-3-270m-it'
        '/resolve/main/gemma3-270m-it-q8-web.task?download=true',
  );

  static const gemma3_1b = OnDeviceModel(
    id: 'gemma3-1b',
    name: 'Gemma 3 1B',
    description:
        'Balanced Gemma 3 — strong coaching quality at half the size of Gemma 4.',
    family: OnDeviceModelFamily.gemma3,
    sizeMb: 500,
    minRamGb: 4,
    requiresHuggingFaceToken: true,
    mobileDownloadUrl:
        'https://huggingface.co/litert-community/Gemma3-1B-IT'
        '/resolve/main/Gemma3-1B-IT_multi-prefill-seq_q4_ekv4096.litertlm?download=true',
  );

  static const qwen3_0_6b = OnDeviceModel(
    id: 'qwen3-0.6b',
    name: 'Qwen3 0.6B',
    description:
        'Compact multilingual model with thinking support. No HuggingFace token required.',
    family: OnDeviceModelFamily.qwen3,
    sizeMb: 586,
    minRamGb: 4,
    requiresHuggingFaceToken: false,
    mobileDownloadUrl:
        'https://huggingface.co/litert-community/Qwen3-0.6B'
        '/resolve/main/Qwen3-0.6B.litertlm?download=true',
  );

  static const List<OnDeviceModel> models = [
    gemma3_270m,
    qwen3_0_6b,
    gemma3_1b,
    gemma4E2b,
  ];

  static OnDeviceModel byId(String? id) {
    if (id == null || id.isEmpty) return gemma4E2b;
    for (final model in models) {
      if (model.id == id) return model;
    }
    return gemma4E2b;
  }

  /// Models compatible with the current platform and optional RAM budget.
  static List<OnDeviceModel> forDevice({
    required bool isWeb,
    int? totalRamBytes,
  }) {
    final ramGb = totalRamBytes == null
        ? null
        : (totalRamBytes / (1024 * 1024 * 1024)).floor();

    const webLitertLmIds = {'gemma4-e2b', 'qwen3-0.6b'};

    return models.where((model) {
      if (isWeb && !webLitertLmIds.contains(model.id)) return false;
      if (ramGb != null && ramGb < model.minRamGb) return false;
      return true;
    }).toList();
  }
}
