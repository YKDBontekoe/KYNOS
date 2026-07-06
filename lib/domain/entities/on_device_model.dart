import 'package:meta/meta.dart';

/// Supported on-device LLM families (maps to flutter_gemma in infrastructure).
enum OnDeviceModelFamily {
  gemma4,
  gemma3,
  gemma3n,
  qwen3,
  qwen2,
  phi,
  functionGemma,
}

/// Capability flags surfaced in the on-device model picker.
enum OnDeviceModelCapability {
  functionCalling,
  thinkingMode,
  vision,
  audio,
  multilingual,
}

/// Picker grouping tier ordered lightweight → flagship.
enum OnDeviceModelTier {
  lightweight,
  balanced,
  flagship,
}

/// Curated lightweight model available for on-device coach inference.
@immutable
class OnDeviceModel {
  const OnDeviceModel({
    required this.id,
    required this.name,
    required this.description,
    required this.family,
    required this.sizeMb,
    required this.minRamGb,
    required this.requiresHuggingFaceToken,
    required this.mobileDownloadUrl,
    required this.capabilities,
    required this.bestFor,
    required this.tier,
    this.webDownloadUrl,
  });

  final String id;
  final String name;
  final String description;
  final OnDeviceModelFamily family;
  final int sizeMb;
  final int minRamGb;
  final bool requiresHuggingFaceToken;
  final String mobileDownloadUrl;
  final String? webDownloadUrl;
  final Set<OnDeviceModelCapability> capabilities;
  final String bestFor;
  final OnDeviceModelTier tier;

  String downloadUrl({required bool isWeb}) {
    if (isWeb && webDownloadUrl != null) return webDownloadUrl!;
    return mobileDownloadUrl;
  }

  bool hasCapability(OnDeviceModelCapability capability) =>
      capabilities.contains(capability);
}
