import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kynos/domain/usecases/health/import_apple_health_export_usecase.dart';
import 'package:kynos/domain/usecases/health/import_workout_usecase.dart';
import 'package:kynos/infrastructure/health/health_infrastructure_providers.dart';

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
