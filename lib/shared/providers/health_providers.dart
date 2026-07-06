import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'package:kynos/core/errors/failures.dart';
import 'package:kynos/domain/entities/health_summary.dart';
import 'package:kynos/domain/entities/workout_route_point.dart';
import 'package:kynos/domain/entities/workout_session.dart';
import 'package:kynos/domain/repositories/health_repository.dart';
import 'package:kynos/domain/usecases/health/import_apple_health_export_usecase.dart';
import 'package:kynos/domain/usecases/health/import_workout_usecase.dart';
import 'package:kynos/infrastructure/health/health_infrastructure_providers.dart';
import 'package:kynos/infrastructure/health/import/apple_health_export_isolate.dart';
import 'package:kynos/infrastructure/health/import/apple_health_export_parser.dart';
import 'package:kynos/infrastructure/health/import/gpx_workout_parser.dart';
import 'package:kynos/shared/utils/picked_file_bytes.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'health_providers.g.dart';

final _logger = Logger();

/// UI-facing state for health import parsing and persistence flows.
class HealthImportState {
  const HealthImportState({
    this.gpxPreview,
    this.appleHealthPreview,
    this.errorMessage,
    this.processingFileName,
    this.progressMessage,
    this.isParsing = false,
    this.isImporting = false,
  });

  final GpxParseResult? gpxPreview;
  final AppleHealthExportParseResult? appleHealthPreview;
  final String? errorMessage;
  final String? processingFileName;
  final String? progressMessage;
  final bool isParsing;
  final bool isImporting;

  bool get isBusy => isParsing || isImporting;
  bool get hasPreview => gpxPreview != null || appleHealthPreview != null;

  HealthImportState copyWith({
    GpxParseResult? gpxPreview,
    AppleHealthExportParseResult? appleHealthPreview,
    String? errorMessage,
    String? processingFileName,
    String? progressMessage,
    bool? isParsing,
    bool? isImporting,
    bool clearGpxPreview = false,
    bool clearAppleHealthPreview = false,
    bool clearErrorMessage = false,
    bool clearProcessingFileName = false,
    bool clearProgressMessage = false,
  }) {
    return HealthImportState(
      gpxPreview: clearGpxPreview ? null : gpxPreview ?? this.gpxPreview,
      appleHealthPreview: clearAppleHealthPreview
          ? null
          : appleHealthPreview ?? this.appleHealthPreview,
      errorMessage: clearErrorMessage ? null : errorMessage ?? this.errorMessage,
      processingFileName: clearProcessingFileName
          ? null
          : processingFileName ?? this.processingFileName,
      progressMessage:
          clearProgressMessage ? null : progressMessage ?? this.progressMessage,
      isParsing: isParsing ?? this.isParsing,
      isImporting: isImporting ?? this.isImporting,
    );
  }
}

class ManualRunImporter {
  const ManualRunImporter(this._ref);

  final riverpod.Ref _ref;

  Future<({WorkoutSession? workout, Failure? failure})> importWorkout({
    required WorkoutSession workout,
  }) async {
    final result = await _ref.read(importWorkoutUseCaseProvider)(
      workout: workout,
    );
    if (result.failure == null) {
      _invalidateHealthProviders(_ref);
    }
    return result;
  }
}

class HealthImportResult {
  const HealthImportResult({
    required this.message,
    this.importedWorkout,
  });

  final String message;
  final WorkoutSession? importedWorkout;
}

/// Canonical health repository binding — merges HealthKit and imported data.
@Riverpod(keepAlive: true)
HealthRepository healthRepository(Ref ref) {
  return ref.watch(compositeHealthRepositoryProvider);
}

@riverpod
Future<HealthSummary?> healthSummary(Ref ref) async {
  final repository = ref.watch(healthRepositoryProvider);

  final result = await repository.getToday();
  if (result.failure != null) {
    _logger.d('Health summary unavailable: ${result.failure}');
    return null;
  }
  return result.summary;
}

@riverpod
Future<List<HealthSummary>> healthHistory(
  Ref ref, {
  int days = 30,
}) async {
  final repository = ref.watch(healthRepositoryProvider);

  final result = await repository.getSummaries(days: days);
  if (result.failure != null) {
    throw result.failure!;
  }
  return result.summaries;
}

@riverpod
Future<List<WorkoutSession>> recentRuns(
  Ref ref, {
  int days = 30,
  int limit = 20,
}) async {
  final repository = ref.watch(healthRepositoryProvider);

  final result = await repository.getRecentRuns(days: days, limit: limit);
  if (result.failure != null) {
    throw result.failure!;
  }
  return result.runs;
}

@riverpod
Future<List<WorkoutRoutePoint>> runRoute(
  Ref ref, {
  required String workoutUuid,
}) async {
  final repository = ref.watch(healthRepositoryProvider);

  final result = await repository.getRunRoute(workoutUuid: workoutUuid);
  if (result.failure != null) {
    throw result.failure!;
  }
  return result.points;
}

final manualRunImportProvider = riverpod.Provider<ManualRunImporter>((ref) {
  return ManualRunImporter(ref);
});

final gpxImportProvider = riverpod.Provider<ImportWorkoutUseCase>((ref) {
  return ref.watch(importWorkoutUseCaseProvider);
});

final appleHealthImportProvider =
    riverpod.Provider<ImportAppleHealthExportUseCase>((ref) {
  return ref.watch(importAppleHealthExportUseCaseProvider);
});

final healthImportNotifierProvider =
    riverpod.NotifierProvider<HealthImportNotifier, HealthImportState>(
  HealthImportNotifier.new,
);

class HealthImportNotifier extends riverpod.Notifier<HealthImportState> {
  @override
  HealthImportState build() => const HealthImportState();

  Future<void> previewFile(PlatformFile file) async {
    final isZip = file.extension?.toLowerCase() == 'zip';
    state = HealthImportState(
      isParsing: true,
      processingFileName: file.name,
      progressMessage: isZip
          ? 'Reading and parsing your Apple Health export. '
              'Large archives can take a minute.'
          : 'Reading GPX route file…',
    );

    try {
      if (isZip) {
        final preview = await _previewAppleHealthExport(file);
        state = HealthImportState(appleHealthPreview: preview);
      } else {
        final preview = await _previewGpx(file);
        state = HealthImportState(gpxPreview: preview);
      }
    } on OutOfMemoryError {
      state = const HealthImportState(
        errorMessage: 'This export is too large for available memory. '
            'Try exporting a shorter date range from the Health app.',
      );
    } on FormatException catch (e) {
      state = HealthImportState(errorMessage: e.message);
    } on Object catch (e) {
      state = HealthImportState(errorMessage: 'Failed to parse file: $e');
    }
  }

  Future<HealthImportResult?> importSelected(PlatformFile? file) async {
    final current = state;
    state = current.copyWith(isImporting: true, clearErrorMessage: true);

    try {
      if (current.appleHealthPreview != null && file != null) {
        return await _importAppleHealthExport(file);
      }
      final preview = current.gpxPreview;
      if (preview != null) {
        return await _importGpx(preview);
      }
      return null;
    } finally {
      state = state.copyWith(isImporting: false);
    }
  }

  Future<GpxParseResult> _previewGpx(PlatformFile file) async {
    final bytes = await readPickedFileBytes(file);
    return const GpxWorkoutParser().parse(
      utf8.decode(bytes, allowMalformed: true),
    );
  }

  Future<AppleHealthExportParseResult> _previewAppleHealthExport(
    PlatformFile file,
  ) async {
    final bytes = file.path == null ? await readPickedFileBytes(file) : null;
    return parseAppleHealthZipAsync(zipPath: file.path, zipBytes: bytes);
  }

  Future<HealthImportResult> _importGpx(GpxParseResult preview) async {
    final result = await ref.read(gpxImportProvider)(
      workout: preview.workout,
      routePoints: preview.routePoints,
    );
    if (result.failure != null) {
      throw result.failure!;
    }
    _invalidateHealthProviders(ref);
    return HealthImportResult(
      message: 'Run imported successfully.',
      importedWorkout: result.workout,
    );
  }

  Future<HealthImportResult> _importAppleHealthExport(PlatformFile file) async {
    final bytes = file.path == null ? await readPickedFileBytes(file) : null;
    final result = await ref.read(appleHealthImportProvider)(
      zipPath: file.path,
      zipBytes: bytes,
    );
    if (result.failure != null) {
      throw result.failure!;
    }
    _invalidateHealthProviders(ref);
    return HealthImportResult(
      message: 'Imported ${result.importedDays} days of metrics and '
          '${result.importedWorkouts} runs.',
    );
  }
}

@riverpod
Future<int> importedWorkoutCount(Ref ref) async {
  final store = ref.watch(importedHealthStoreProvider);
  return store.workoutCount();
}

void _invalidateHealthProviders(riverpod.Ref ref) {
  ref.invalidate(healthSummaryProvider);
  ref.invalidate(healthHistoryProvider);
  ref.invalidate(recentRunsProvider);
  ref.invalidate(importedWorkoutCountProvider);
}

/// Handles the HealthKit permission request triggered from the UI.
@Riverpod(keepAlive: true)
class HealthPermissionsNotifier extends _$HealthPermissionsNotifier {
  @override
  AsyncValue<bool> build() => const AsyncData(false);

  Future<void> request() async {
    if (kIsWeb) {
      state = AsyncError(
        UnsupportedError(
          'HealthKit is only available on iOS. Import runs from Settings instead.',
        ),
        StackTrace.current,
      );
      return;
    }

    state = const AsyncLoading();
    try {
      final repo = ref.read(healthRepositoryProvider);
      final success = await repo.requestPermissions();
      state = AsyncData(success);
      if (success) {
        _invalidateHealthProviders(ref);
      }
    } on Object catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

/// Clears all imported workouts and refreshes health providers.
@Riverpod(keepAlive: true)
class ImportedHealthDataNotifier extends _$ImportedHealthDataNotifier {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> clearAll() async {
    state = const AsyncLoading();
    try {
      final store = ref.read(importedHealthStoreProvider);
      await store.clearAll();
      state = const AsyncData(null);
      _invalidateHealthProviders(ref);
    } on Object catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
