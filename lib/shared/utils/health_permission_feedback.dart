import 'package:kynos/shared/utils/health_platform_labels.dart';

/// User-facing copy for health permission flows — never expose raw exceptions.
abstract final class HealthPermissionFeedback {
  static String connectionFailedMessage() {
    return 'Could not connect to health data. Try again, or import runs from Settings.';
  }

  static String permissionDeniedMessage(String platform) {
    return '$platform permission not granted. ${HealthPlatformLabels.settingsHint()}';
  }

  static String connectedMessage(String platform) => '$platform connected.';
}
