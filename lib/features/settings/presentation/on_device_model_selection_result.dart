/// Result returned when the user picks an on-device model in Settings.
class OnDeviceModelSelectionResult {
  const OnDeviceModelSelectionResult({
    required this.modelName,
    required this.needsDownload,
  });

  final String modelName;
  final bool needsDownload;
}
