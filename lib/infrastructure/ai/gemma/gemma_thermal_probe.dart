import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Reads platform thermal / power-save signals for conservative Gemma routing.
abstract final class GemmaThermalProbe {
  static const _channel = MethodChannel('kynos/device_thermal');

  static Future<bool> isThermallyThrottled() async {
    if (kIsWeb) return false;

    try {
      final throttled =
          await _channel.invokeMethod<bool>('isThermallyThrottled');
      return throttled ?? false;
    } on Object {
      return false;
    }
  }
}
