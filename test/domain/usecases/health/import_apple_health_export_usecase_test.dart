import 'package:flutter_test/flutter_test.dart';
import 'package:kynos/core/errors/failures.dart';
import 'package:kynos/domain/entities/health_summary.dart';
import 'package:kynos/domain/entities/workout_route_point.dart';
import 'package:kynos/domain/entities/workout_session.dart';
import 'package:kynos/domain/repositories/imported_health_persistence.dart';
import 'package:kynos/domain/usecases/health/apple_health_export_parser.dart';
import 'package:kynos/domain/usecases/health/import_apple_health_export_usecase.dart';
import 'package:kynos/domain/usecases/health/import_workout_usecase.dart';

void main() {
  group('ImportAppleHealthExportUseCase', () {
    late _FakeImportedHealthPersistence store;
    late _FakeAppleHealthExportParser parser;
    late ImportAppleHealthExportUseCase useCase;

    setUp(() {
      store = _FakeImportedHealthPersistence();
      parser = _FakeAppleHealthExportParser(_parseResult());
      useCase = ImportAppleHealthExportUseCase(
        store: store,
        parser: parser,
        importWorkout: ImportWorkoutUseCase(store),
      );
    });

    test('persists daily summaries and running workouts', () async {
      final result = await useCase(
        zipBytes: const [1, 2, 3],
        now: DateTime(2026, 4, 22),
      );

      expect(result.failure, isNull);
      expect(result.importedDays, 1);
      expect(result.importedWorkouts, 1);
      expect(result.recordCount, 4);
      expect(await store.workoutCount(), 1);
      expect(store.summaries, hasLength(1));
      expect(store.summaries.first.steps, 8421);
      expect(parser.lastZipBytes, const [1, 2, 3]);
    });

    test('maps parser format errors to HealthDataFailure', () async {
      parser.error = const FormatException('Could not find export.xml');

      final result = await useCase(zipBytes: const []);

      expect(result.importedWorkouts, 0);
      expect(result.failure, isA<HealthDataFailure>());
    });

    test('maps store failures to StorageFailure', () async {
      store.failSavingSummaries = true;

      final result = await useCase(zipBytes: const [1]);

      expect(result.importedWorkouts, 0);
      expect(result.failure, isA<StorageFailure>());
    });
  });
}

AppleHealthExportParseResult _parseResult() {
  return AppleHealthExportParseResult(
    summaries: [
      HealthSummary(
        date: DateTime(2026, 4, 20),
        steps: 8421,
      ),
    ],
    workouts: [
      AppleHealthWorkoutImport(
        workout: WorkoutSession(
          id: 'imported:test',
          start: DateTime(2026, 4, 20, 7),
          end: DateTime(2026, 4, 20, 7, 45),
          workoutType: 'running',
          distanceMeters: 5000,
          sourceName: 'Apple Health',
        ),
      ),
    ],
    recordCount: 4,
    skippedWorkouts: 0,
  );
}

class _FakeAppleHealthExportParser implements AppleHealthExportParser {
  _FakeAppleHealthExportParser(this.result);

  final AppleHealthExportParseResult result;
  Object? error;
  List<int>? lastZipBytes;
  String? lastZipPath;

  @override
  Future<AppleHealthExportParseResult> parse({
    List<int>? zipBytes,
    String? zipPath,
  }) async {
    lastZipBytes = zipBytes;
    lastZipPath = zipPath;
    final error = this.error;
    if (error is FormatException) {
      throw error;
    }
    if (error != null) {
      throw error;
    }
    return result;
  }
}

class _FakeImportedHealthPersistence implements ImportedHealthPersistence {
  final workouts = <WorkoutSession>[];
  final summaries = <HealthSummary>[];
  bool failSavingSummaries = false;

  @override
  Future<void> clearAll() async {
    workouts.clear();
    summaries.clear();
  }

  @override
  Future<List<HealthSummary>> getSummaries({required DateTime since}) async =>
      summaries.where((summary) => !summary.date.isBefore(since)).toList();

  @override
  Future<List<WorkoutRoutePoint>> getRoutePoints(String workoutId) async => [];

  @override
  Future<List<WorkoutSession>> getWorkouts({
    required DateTime since,
    int? limit,
  }) async =>
      workouts.where((workout) => !workout.start.isBefore(since)).toList();

  @override
  Future<void> saveSummaries(List<HealthSummary> summaries) async {
    if (failSavingSummaries) {
      throw Exception('disk full');
    }
    this.summaries.addAll(summaries);
  }

  @override
  Future<void> saveWorkout({
    required WorkoutSession workout,
    List<WorkoutRoutePoint> routePoints = const [],
  }) async => workouts.add(workout);

  @override
  Future<int> workoutCount() async => workouts.length;
}
