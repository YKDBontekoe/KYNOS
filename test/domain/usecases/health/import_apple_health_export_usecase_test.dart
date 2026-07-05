import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kynos/core/errors/failures.dart';
import 'package:kynos/domain/entities/health_summary.dart';
import 'package:kynos/domain/entities/workout_route_point.dart';
import 'package:kynos/domain/entities/workout_session.dart';
import 'package:kynos/domain/usecases/health/import_apple_health_export_usecase.dart';
import 'package:kynos/domain/usecases/health/import_workout_usecase.dart';
import 'package:kynos/infrastructure/health/drift_imported_health_store.dart';
import 'package:kynos/infrastructure/health/imported_health_database.dart';
import 'package:kynos/infrastructure/health/imported_health_store.dart';

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
          ArchiveFile('export.xml', utf8.encode(xml).length, utf8.encode(xml)),
        )
        ..addFile(
          ArchiveFile(
            'workout-routes/route_2026-04-20.gpx',
            utf8.encode(gpx).length,
            utf8.encode(gpx),
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

    test('maps missing export.xml to HealthDataFailure', () async {
      final emptyZip = ZipEncoder().encode(Archive());
      final result = await useCase(zipBytes: emptyZip);

      expect(result.importedWorkouts, 0);
      expect(result.failure, isA<HealthDataFailure>());
    });

    test('maps store failures to StorageFailure', () async {
      final failingUseCase = ImportAppleHealthExportUseCase(
        store: _FailingImportedHealthStore(),
        importWorkout: ImportWorkoutUseCase(_FailingImportedHealthStore()),
      );

      final result = await failingUseCase(zipBytes: zipBytes);

      expect(result.importedWorkouts, 0);
      expect(result.failure, isA<StorageFailure>());
    });
  });
}

class _FailingImportedHealthStore implements ImportedHealthStore {
  @override
  Future<void> clearAll() => throw UnimplementedError();

  @override
  Future<List<HealthSummary>> getSummaries({required DateTime since}) =>
      throw UnimplementedError();

  @override
  Future<List<WorkoutRoutePoint>> getRoutePoints(String workoutId) =>
      throw UnimplementedError();

  @override
  Future<List<WorkoutSession>> getWorkouts({
    required DateTime since,
    int? limit,
  }) =>
      throw UnimplementedError();

  @override
  Future<void> saveSummaries(List<HealthSummary> summaries) async {
    throw Exception('disk full');
  }

  @override
  Future<void> saveWorkout({
    required WorkoutSession workout,
    List<WorkoutRoutePoint> routePoints = const [],
  }) =>
      throw UnimplementedError();

  @override
  Future<int> workoutCount() => throw UnimplementedError();
}
