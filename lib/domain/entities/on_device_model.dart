import 'package:meta/meta.dart';

/// Supported on-device LLM families (maps to flutter_gemma in infrastructure).
enum OnDeviceModelFamily {
  gemma4,
  gemma3,
  qwen3,
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

  String downloadUrl({required bool isWeb}) {
    if (isWeb && webDownloadUrl != null) return webDownloadUrl!;
    return mobileDownloadUrl;
  }
}
