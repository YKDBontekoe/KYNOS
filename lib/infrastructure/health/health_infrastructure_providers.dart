import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kynos/domain/repositories/health_repository.dart';
import 'package:kynos/domain/usecases/health/apple_health_export_parser.dart';
import 'package:kynos/domain/usecases/health/import_apple_health_export_usecase.dart';
import 'package:kynos/domain/usecases/health/import_workout_usecase.dart';
import 'package:kynos/infrastructure/health/composite_health_repository.dart';
import 'package:kynos/infrastructure/health/health_kit_repository.dart';
import 'package:kynos/infrastructure/health/import/apple_health_export_isolate.dart';
import 'package:kynos/infrastructure/health/imported_health_repository.dart';
import 'package:kynos/infrastructure/health/imported_health_store.dart';
import 'package:kynos/infrastructure/health/platform_imported_health_store_native.dart'
    if (dart.library.html) 'package:kynos/infrastructure/health/platform_imported_health_store_web.dart';

final importedHealthStoreProvider = Provider<ImportedHealthStore>((ref) {
  return createPlatformImportedHealthStore(ref);
});

final importedHealthRepositoryProvider = Provider<HealthRepository>((ref) {
  return ImportedHealthRepository(ref.watch(importedHealthStoreProvider));
});

final healthKitRepositoryProvider = Provider<HealthRepository>((ref) {
  return HealthKitRepository();
});

final compositeHealthRepositoryProvider = Provider<HealthRepository>((ref) {
  return CompositeHealthRepository(
    healthKit: ref.watch(healthKitRepositoryProvider),
    imported: ref.watch(importedHealthRepositoryProvider),
  );
});

final appleHealthExportParserProvider = Provider<AppleHealthExportParser>((ref) {
  return const IsolateAppleHealthExportParser();
});

final importWorkoutUseCaseProvider = Provider<ImportWorkoutUseCase>((ref) {
  return ImportWorkoutUseCase(ref.watch(importedHealthStoreProvider));
});

final importAppleHealthExportUseCaseProvider =
    Provider<ImportAppleHealthExportUseCase>((ref) {
  return ImportAppleHealthExportUseCase(
    store: ref.watch(importedHealthStoreProvider),
    parser: ref.watch(appleHealthExportParserProvider),
    importWorkout: ref.watch(importWorkoutUseCaseProvider),
  );
});
