import 'package:flutter/foundation.dart';

/// Platform-aware labels for health data sources.
abstract final class HealthPlatformLabels {
  static String platformName() {
    if (kIsWeb) return 'health data';
    return switch (defaultTargetPlatform) {
      TargetPlatform.iOS => 'HealthKit',
      TargetPlatform.android => 'Health Connect',
      _ => 'health data',
    };
  }

  static String connectLabel() => 'Connect ${platformName()}';

  static String connectedLabel() => '${platformName()} connected';

  static String settingsHint() {
    return switch (defaultTargetPlatform) {
      TargetPlatform.iOS =>
        'Enable access in Settings > Health > Data Access & Devices > Kynos.',
      TargetPlatform.android =>
        'Enable access in Settings > Apps > Kynos > Permissions > Health Connect.',
      _ => 'Enable health permissions in system settings.',
    };
  }

  static String sideloadHint() {
    final platform = platformName();
    return 'Sideloaded installs may not access $platform. Import your '
        'Apple Health export.zip, a GPX file, or log runs manually.';
  }

  static String characterEmptyHint() {
    if (kIsWeb) {
      return 'Import runs or log them manually to unlock your class assignment.';
    }
    return 'Connect ${platformName()} and log a few runs to unlock your '
        'class assignment.';
  }
}
