import 'package:kynos/core/errors/failures.dart';
import 'package:kynos/domain/usecases/health/import_workout_usecase.dart';
import 'package:kynos/infrastructure/health/import/apple_health_export_parser.dart';
import 'package:kynos/infrastructure/health/imported_health_store.dart';

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
    required ImportedHealthStore store,
    required ImportWorkoutUseCase importWorkout,
    AppleHealthExportParser? parser,
  })  : _store = store,
        _importWorkout = importWorkout,
        _parser = parser ?? const AppleHealthExportParser();

  final ImportedHealthStore _store;
  final ImportWorkoutUseCase _importWorkout;
  final AppleHealthExportParser _parser;

  Future<ImportAppleHealthExportResult> call({
    required List<int> zipBytes,
    DateTime? now,
  }) async {
    try {
      final parsed = _parser.parseZip(zipBytes);
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
