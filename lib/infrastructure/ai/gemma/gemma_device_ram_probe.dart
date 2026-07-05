import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:kynos/domain/utils/gemma_device_capability.dart';
import 'package:logger/logger.dart';

final _logger = Logger();

/// Probes device RAM for [GemmaDeviceCapabilitySelector].
abstract final class GemmaDeviceRamProbe {
  static Future<int?> totalRamBytes() async {
    if (kIsWeb) return null;

    final plugin = DeviceInfoPlugin();
    try {
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        final ios = await plugin.iosInfo;
        return _iosRamFromMachine(ios.utsname.machine);
      }
      if (defaultTargetPlatform == TargetPlatform.android) {
        final android = await plugin.androidInfo;
        if (android.physicalRamSize > 0) {
          return android.physicalRamSize * 1024 * 1024;
        }
      }
    } on Object catch (e, st) {
      _logger.w('RAM probe failed', error: e, stackTrace: st);
      return null;
    }
    return null;
  }

  static int? _iosRamFromMachine(String machine) {
    const eightGbMachines = {
      'iPhone17,1', 'iPhone17,2', 'iPhone17,3', 'iPhone17,4',
    };
    const sixGbMachines = {
      'iPhone14,2', 'iPhone14,3', 'iPhone15,2', 'iPhone15,3',
      'iPhone16,1', 'iPhone16,2', 'iPhone16,3', 'iPhone16,4',
    };
    const fourGbMachines = {
      'iPhone13,1', 'iPhone13,2', 'iPhone13,3', 'iPhone13,4',
      'iPhone14,4', 'iPhone14,5', 'iPhone15,4', 'iPhone15,5',
    };

    if (eightGbMachines.contains(machine)) {
      return 8 * 1024 * 1024 * 1024;
    }
    if (sixGbMachines.contains(machine)) {
      return 6 * 1024 * 1024 * 1024;
    }
    if (fourGbMachines.contains(machine)) {
      return 4 * 1024 * 1024 * 1024;
    }
    if (machine.startsWith('iPhone')) {
      return null;
    }
    return null;
  }
}
