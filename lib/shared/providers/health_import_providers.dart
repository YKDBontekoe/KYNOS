import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kynos/domain/usecases/health/import_apple_health_export_usecase.dart';
import 'package:kynos/domain/usecases/health/import_workout_usecase.dart';
import 'package:kynos/infrastructure/health/health_infrastructure_providers.dart';

export 'package:kynos/infrastructure/health/import/apple_health_export_isolate.dart'
    show parseAppleHealthZipAsync;
export 'package:kynos/infrastructure/health/import/apple_health_export_parser.dart'
    show AppleHealthExportParseResult;
export 'package:kynos/infrastructure/health/import/gpx_workout_parser.dart'
    show GpxParseResult, GpxWorkoutParser;

final importWorkoutUseCaseProvider = Provider<ImportWorkoutUseCase>((ref) {
  return ImportWorkoutUseCase(ref.watch(importedHealthStoreProvider));
});

final importAppleHealthExportUseCaseProvider =
    Provider<ImportAppleHealthExportUseCase>((ref) {
  return ImportAppleHealthExportUseCase(
    store: ref.watch(importedHealthStoreProvider),
    importWorkout: ref.watch(importWorkoutUseCaseProvider),
  );
});
