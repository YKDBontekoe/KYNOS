import 'dart:io';

import 'package:kynos/core/constants/app_constants.dart';
import 'package:kynos/core/errors/failures.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Verifies zero-knowledge constraints before biomechanics training starts.
class LocalSyncPrivacyGuard {
  Future<Failure?> verifyNoRawSensorDataStagedForCloudSync() async {
    if (!AppConstants.zeroKnowledgeMode) {
      return const PrivacyConstraintFailure(
        'Zero-Knowledge mode disabled; training blocked.',
      );
    }

    final Directory docsDirectory = await getApplicationDocumentsDirectory();
    final syncRoots = <Directory>[
      Directory(p.join(docsDirectory.path, 'sync')),
      Directory(p.join(docsDirectory.path, 'cloud_sync')),
      Directory(p.join(docsDirectory.path, 'upload_queue')),
      Directory(p.join(docsDirectory.path, 'staging')),
    ];

    for (final directory in syncRoots) {
      if (!await directory.exists()) {
        continue;
      }
      await for (final entity in directory.list(
        recursive: true,
        followLinks: false,
      )) {
        if (entity is! File) {
          continue;
        }
        final fileName = p.basename(entity.path).toLowerCase();
        final isPotentiallyRawBiometric =
            fileName.contains('health') ||
            fileName.contains('biometric') ||
            fileName.contains('gps') ||
            fileName.contains('sensor');

        if (!isPotentiallyRawBiometric) {
          continue;
        }

        final fileLength = await entity.length();
        if (fileLength > 0) {
          return PrivacyConstraintFailure(
            'Raw biometric payload staged for cloud sync at ${entity.path}.',
          );
        }
      }
    }

    return null;
  }
}
