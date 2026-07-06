import 'package:kynos/core/errors/failures.dart';
import 'package:kynos/domain/repositories/imported_health_persistence.dart';
import 'package:kynos/domain/usecases/health/apple_health_export_parser.dart';
import 'package:kynos/domain/usecases/health/import_workout_usecase.dart';

/// Result of importing an Apple Health `export.zip` archive.
class ImportAppleHealthExportResult {
  const ImportAppleHealthExportResult({
    required this.importedWorkouts,
    required this.skippedWorkouts,
    required this.importedDays,
    required this.recordCount,
    this.failure,
  });

  final int importedWorkouts;
  final int skippedWorkouts;
  final int importedDays;
  final int recordCount;
  final Failure? failure;
}

/// Parses and persists an Apple Health export archive.
class ImportAppleHealthExportUseCase {
  const ImportAppleHealthExportUseCase({
    required ImportedHealthPersistence store,
    required AppleHealthExportParser parser,
    required ImportWorkoutUseCase importWorkout,
  })  : _store = store,
        _parser = parser,
        _importWorkout = importWorkout;

  final ImportedHealthPersistence _store;
  final AppleHealthExportParser _parser;
  final ImportWorkoutUseCase _importWorkout;

  Future<ImportAppleHealthExportResult> call({
    List<int>? zipBytes,
    String? zipPath,
    DateTime? now,
  }) async {
    try {
      final parsed = await _parser.parse(
        zipPath: zipPath,
        zipBytes: zipBytes,
      );
      await _store.saveSummaries(parsed.summaries);

      var importedWorkouts = 0;
      var skippedWorkouts = parsed.skippedWorkouts;

      for (final item in parsed.workouts) {
        final result = await _importWorkout(
          workout: item.workout,
          routePoints: item.routePoints,
          now: now,
        );
        if (result.failure != null) {
          skippedWorkouts += 1;
        } else {
          importedWorkouts += 1;
        }
      }

      return ImportAppleHealthExportResult(
        importedWorkouts: importedWorkouts,
        skippedWorkouts: skippedWorkouts,
        importedDays: parsed.summaries.length,
        recordCount: parsed.recordCount,
      );
    } on FormatException catch (e) {
      return ImportAppleHealthExportResult(
        importedWorkouts: 0,
        skippedWorkouts: 0,
        importedDays: 0,
        recordCount: 0,
        failure: HealthDataFailure(e.message),
      );
    } on OutOfMemoryError {
      return const ImportAppleHealthExportResult(
        importedWorkouts: 0,
        skippedWorkouts: 0,
        importedDays: 0,
        recordCount: 0,
        failure: HealthDataFailure(
          'This export is too large for available memory. '
          'Try exporting a shorter date range from the Health app.',
        ),
      );
    } on Object catch (e) {
      return ImportAppleHealthExportResult(
        importedWorkouts: 0,
        skippedWorkouts: 0,
        importedDays: 0,
        recordCount: 0,
        failure: StorageFailure(e.toString()),
      );
    }
  }
}
