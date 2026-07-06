import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';

final _logger = Logger();

/// Platform signals used for on-device Gemma tier selection.
abstract final class DeviceCapabilityChannel {
  static const _channel = MethodChannel('kynos/device_thermal');

  static Future<int?> physicalMemoryBytes() async {
    if (kIsWeb) return null;

    try {
      final bytes = await _channel.invokeMethod<int>('physicalMemoryBytes');
      if (bytes == null || bytes <= 0) return null;
      return bytes;
    } on Object catch (error, stackTrace) {
      _logger.w(
        'physicalMemoryBytes probe failed',
        error: error,
        stackTrace: stackTrace,
      );
      return null;
    }
  }
}

/// Probes device RAM for [GemmaDeviceCapabilitySelector].
abstract final class GemmaDeviceRamProbe {
  static Future<int?> totalRamBytes() async {
    if (kIsWeb) return null;

    try {
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        return DeviceCapabilityChannel.physicalMemoryBytes();
      }
      if (defaultTargetPlatform == TargetPlatform.android) {
        final android = await DeviceInfoPlugin().androidInfo;
        if (android.physicalRamSize > 0) {
          return android.physicalRamSize * 1024 * 1024;
        }
      }
    } on Object catch (error, stackTrace) {
      _logger.w('RAM probe failed', error: error, stackTrace: stackTrace);
      return null;
    }
    return null;
  }
}
