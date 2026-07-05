import 'dart:io';

import 'package:archive/archive.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kynos/domain/usecases/health/import_apple_health_export_usecase.dart';
import 'package:kynos/domain/usecases/health/import_workout_usecase.dart';
import 'package:kynos/infrastructure/health/drift_imported_health_store.dart';
import 'package:kynos/infrastructure/health/imported_health_database.dart';

void main() {
  group('ImportAppleHealthExportUseCase', () {
    late ImportedHealthDatabase db;
    late DriftImportedHealthStore store;
    late ImportAppleHealthExportUseCase useCase;
    late List<int> zipBytes;

    setUp(() async {
      db = ImportedHealthDatabase(NativeDatabase.memory());
      store = DriftImportedHealthStore(db);
      useCase = ImportAppleHealthExportUseCase(
        store: store,
        importWorkout: ImportWorkoutUseCase(store),
      );

      final xml = await File('test/fixtures/apple_health_export.xml')
          .readAsString();
      final gpx =
          await File('test/fixtures/sample_run.gpx').readAsString();
      final archive = Archive()
        ..addFile(
          ArchiveFile('export.xml', xml.length, xml.codeUnits),
        )
        ..addFile(
          ArchiveFile(
            'workout-routes/route_2026-04-20.gpx',
            gpx.length,
            gpx.codeUnits,
          ),
        );
      zipBytes = ZipEncoder().encode(archive);
    });

    tearDown(() async {
      await db.close();
    });

    test('persists daily summaries and running workouts', () async {
      final result = await useCase(
        zipBytes: zipBytes,
        now: DateTime(2026, 4, 22),
      );

      expect(result.failure, isNull);
      expect(result.importedDays, greaterThan(0));
      expect(result.importedWorkouts, 1);
      expect(await store.workoutCount(), 1);

      final summaries = await store.getSummaries(
        since: DateTime(2026, 4, 1),
      );
      expect(summaries, isNotEmpty);
      expect(summaries.first.steps, 8421);
    });
  });
}
