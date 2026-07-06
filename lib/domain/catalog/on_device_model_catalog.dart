import 'package:kynos/core/constants/app_constants.dart';
import 'package:kynos/domain/entities/on_device_model.dart';

/// Curated catalog of LiteRT-LM models supported by KYNOS on-device coach.
abstract final class OnDeviceModelCatalog {
  static const defaultModelId = 'gemma4-e2b';

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
    capabilities: {OnDeviceModelCapability.multilingual},
    bestFor: 'Lowest RAM footprint',
    tier: OnDeviceModelTier.lightweight,
  );

  static const functiongemma_270m = OnDeviceModel(
    id: 'functiongemma-270m',
    name: 'FunctionGemma 270M',
    description:
        'Specialized for structured tool and function calling on-device.',
    family: OnDeviceModelFamily.functionGemma,
    sizeMb: 284,
    minRamGb: 4,
    requiresHuggingFaceToken: true,
    mobileDownloadUrl:
        'https://huggingface.co/sasha-denisov/function-gemma-270M-it'
        '/resolve/main/functiongemma-270M-it.litertlm?download=true',
    webDownloadUrl:
        'https://huggingface.co/sasha-denisov/function-gemma-270M-it'
        '/resolve/main/functiongemma-270M-it.litertlm?download=true',
    capabilities: {
      OnDeviceModelCapability.functionCalling,
      OnDeviceModelCapability.multilingual,
    },
    bestFor: 'Agentic tool use',
    tier: OnDeviceModelTier.lightweight,
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
    capabilities: {
      OnDeviceModelCapability.functionCalling,
      OnDeviceModelCapability.thinkingMode,
      OnDeviceModelCapability.multilingual,
    },
    bestFor: 'Compact multilingual chat',
    tier: OnDeviceModelTier.lightweight,
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
    capabilities: {
      OnDeviceModelCapability.functionCalling,
      OnDeviceModelCapability.multilingual,
    },
    bestFor: 'Balanced text coaching',
    tier: OnDeviceModelTier.balanced,
  );

  static const qwen2_5_1_5b = OnDeviceModel(
    id: 'qwen2.5-1.5b',
    name: 'Qwen 2.5 1.5B',
    description:
        'Strong multilingual instruction model with function-calling support.',
    family: OnDeviceModelFamily.qwen2,
    sizeMb: 1600,
    minRamGb: 4,
    requiresHuggingFaceToken: false,
    mobileDownloadUrl:
        'https://huggingface.co/litert-community/Qwen2.5-1.5B-Instruct'
        '/resolve/main/Qwen2.5-1.5B-Instruct_multi-prefill-seq_q8_ekv4096.litertlm?download=true',
    capabilities: {
      OnDeviceModelCapability.functionCalling,
      OnDeviceModelCapability.multilingual,
    },
    bestFor: 'Multilingual coaching',
    tier: OnDeviceModelTier.balanced,
  );

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
    capabilities: {
      OnDeviceModelCapability.functionCalling,
      OnDeviceModelCapability.thinkingMode,
      OnDeviceModelCapability.vision,
      OnDeviceModelCapability.audio,
      OnDeviceModelCapability.multilingual,
    },
    bestFor: 'Best on-device coach quality',
    tier: OnDeviceModelTier.flagship,
  );

  static const gemma3nE2b = OnDeviceModel(
    id: 'gemma3n-e2b',
    name: 'Gemma3n E2B',
    description:
        'Multimodal Gemma 3 Nano with vision support for on-device image understanding.',
    family: OnDeviceModelFamily.gemma3n,
    sizeMb: 3100,
    minRamGb: 6,
    requiresHuggingFaceToken: true,
    mobileDownloadUrl:
        'https://huggingface.co/google/gemma-3n-E2B-it-litert-lm'
        '/resolve/main/gemma-3n-E2B-it-int4.litertlm?download=true',
    webDownloadUrl:
        'https://huggingface.co/google/gemma-3n-E2B-it-litert-lm'
        '/resolve/main/gemma-3n-E2B-it-int4-Web.litertlm?download=true',
    capabilities: {
      OnDeviceModelCapability.functionCalling,
      OnDeviceModelCapability.vision,
      OnDeviceModelCapability.multilingual,
    },
    bestFor: 'Multimodal chat',
    tier: OnDeviceModelTier.flagship,
  );

  static const phi4Mini = OnDeviceModel(
    id: 'phi-4-mini',
    name: 'Phi-4 Mini',
    description:
        'Advanced reasoning and instruction following from Microsoft Phi-4.',
    family: OnDeviceModelFamily.phi,
    sizeMb: 3900,
    minRamGb: 6,
    requiresHuggingFaceToken: false,
    mobileDownloadUrl:
        'https://huggingface.co/litert-community/Phi-4-mini-instruct'
        '/resolve/main/Phi-4-mini-instruct_multi-prefill-seq_q8_ekv4096.litertlm?download=true',
    webDownloadUrl:
        'https://huggingface.co/litert-community/Phi-4-mini-instruct'
        '/resolve/main/Phi-4-mini-instruct_multi-prefill-seq_q8_ekv4096.litertlm?download=true',
    capabilities: {
      OnDeviceModelCapability.functionCalling,
      OnDeviceModelCapability.multilingual,
    },
    bestFor: 'Advanced reasoning',
    tier: OnDeviceModelTier.flagship,
  );

  static const gemma4E4b = OnDeviceModel(
    id: 'gemma4-e4b',
    name: 'Gemma 4 E4B',
    description:
        'Flagship Gemma 4 with higher capacity — best quality on high-RAM phones.',
    family: OnDeviceModelFamily.gemma4,
    sizeMb: 3700,
    minRamGb: 8,
    requiresHuggingFaceToken: true,
    mobileDownloadUrl:
        'https://huggingface.co/litert-community/gemma-4-E4B-it-litert-lm'
        '/resolve/main/gemma-4-E4B-it.litertlm?download=true',
    webDownloadUrl:
        'https://huggingface.co/litert-community/gemma-4-E4B-it-litert-lm'
        '/resolve/main/gemma-4-E4B-it-web.litertlm?download=true',
    capabilities: {
      OnDeviceModelCapability.functionCalling,
      OnDeviceModelCapability.thinkingMode,
      OnDeviceModelCapability.vision,
      OnDeviceModelCapability.audio,
      OnDeviceModelCapability.multilingual,
    },
    bestFor: 'Maximum on-device quality',
    tier: OnDeviceModelTier.flagship,
  );

  static const List<OnDeviceModel> models = [
    gemma3_270m,
    functiongemma_270m,
    qwen3_0_6b,
    gemma3_1b,
    qwen2_5_1_5b,
    gemma4E2b,
    gemma3nE2b,
    phi4Mini,
    gemma4E4b,
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

    const webLitertLmIds = {
      'gemma4-e2b',
      'gemma4-e4b',
      'gemma3n-e2b',
      'qwen3-0.6b',
      'functiongemma-270m',
      'phi-4-mini',
    };

    return models.where((model) {
      if (isWeb && !webLitertLmIds.contains(model.id)) return false;
      if (ramGb != null && ramGb < model.minRamGb) return false;
      return true;
    }).toList();
  }

  /// Device-compatible models grouped by tier for the picker UI.
  static Map<OnDeviceModelTier, List<OnDeviceModel>> modelsGroupedByTier({
    required bool isWeb,
    int? totalRamBytes,
    Set<OnDeviceModelCapability>? requiredCapabilities,
  }) {
    final compatible = forDevice(isWeb: isWeb, totalRamBytes: totalRamBytes);
    final filtered = requiredCapabilities == null || requiredCapabilities.isEmpty
        ? compatible
        : compatible
            .where(
              (model) => requiredCapabilities.every(model.hasCapability),
            )
            .toList();

    return {
      for (final tier in OnDeviceModelTier.values)
        tier: filtered.where((model) => model.tier == tier).toList(),
    };
  }
}
