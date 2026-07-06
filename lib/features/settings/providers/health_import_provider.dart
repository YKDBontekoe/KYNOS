import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:kynos/domain/entities/workout_session.dart';
import 'package:kynos/infrastructure/health/import/apple_health_export_isolate.dart';
import 'package:kynos/infrastructure/health/import/apple_health_export_parser.dart';
import 'package:kynos/infrastructure/health/import/gpx_workout_parser.dart';
import 'package:kynos/shared/providers/health_import_providers.dart';
import 'package:kynos/shared/providers/health_providers.dart';
import 'package:kynos/shared/utils/picked_file_bytes.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'health_import_provider.g.dart';

class HealthImportState {
  const HealthImportState({
    this.gpxPreview,
    this.zipPreview,
    this.pickedFile,
    this.error,
    this.isParsing = false,
    this.isImporting = false,
    this.processingFileName,
    this.progressMessage,
    this.importMessage,
    this.importedWorkout,
    this.errorToken = 0,
  });

  final GpxParseResult? gpxPreview;
  final AppleHealthExportParseResult? zipPreview;
  final PlatformFile? pickedFile;
  final String? error;
  final bool isParsing;
  final bool isImporting;
  final String? processingFileName;
  final String? progressMessage;
  final String? importMessage;
  final WorkoutSession? importedWorkout;
  final int errorToken;

  bool get isBusy => isParsing || isImporting;

  HealthImportState copyWith({
    GpxParseResult? gpxPreview,
    AppleHealthExportParseResult? zipPreview,
    PlatformFile? pickedFile,
    String? error,
    bool? isParsing,
    bool? isImporting,
    String? processingFileName,
    String? progressMessage,
    String? importMessage,
    WorkoutSession? importedWorkout,
    int? errorToken,
    bool clearGpxPreview = false,
    bool clearZipPreview = false,
    bool clearPickedFile = false,
    bool clearError = false,
    bool clearProcessingFileName = false,
    bool clearProgressMessage = false,
    bool clearImportMessage = false,
    bool clearImportedWorkout = false,
  }) {
    return HealthImportState(
      gpxPreview: clearGpxPreview ? null : (gpxPreview ?? this.gpxPreview),
      zipPreview: clearZipPreview ? null : (zipPreview ?? this.zipPreview),
      pickedFile: clearPickedFile ? null : (pickedFile ?? this.pickedFile),
      error: clearError ? null : (error ?? this.error),
      isParsing: isParsing ?? this.isParsing,
      isImporting: isImporting ?? this.isImporting,
      processingFileName: clearProcessingFileName
          ? null
          : (processingFileName ?? this.processingFileName),
      progressMessage: clearProgressMessage
          ? null
          : (progressMessage ?? this.progressMessage),
      importMessage:
          clearImportMessage ? null : (importMessage ?? this.importMessage),
      importedWorkout: clearImportedWorkout
          ? null
          : (importedWorkout ?? this.importedWorkout),
      errorToken: errorToken ?? this.errorToken,
    );
  }
}

@riverpod
class HealthImport extends _$HealthImport {
  @override
  HealthImportState build() => const HealthImportState();

  void clearImportFeedback() {
    state = state.copyWith(clearImportMessage: true, clearImportedWorkout: true);
  }

  Future<void> pickFile() async {
    state = state.copyWith(
      clearGpxPreview: true,
      clearZipPreview: true,
      clearPickedFile: true,
      clearError: true,
      clearProcessingFileName: true,
      clearProgressMessage: true,
      clearImportMessage: true,
      clearImportedWorkout: true,
    );

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['gpx', 'zip'],
      withData: kIsWeb,
    );

    if (result == null || result.files.isEmpty) return;

    final file = result.files.single;
    final extension = file.extension?.toLowerCase();
    final isZip = extension == 'zip';

    state = state.copyWith(
      isParsing: true,
      processingFileName: file.name,
      progressMessage: isZip
          ? 'Reading and parsing your Apple Health export. '
              'Large archives can take a minute.'
          : 'Reading GPX route file…',
    );

    try {
      if (isZip) {
        final bytes = file.path == null ? await readPickedFileBytes(file) : null;
        final parsed = await parseAppleHealthZipAsync(
          zipPath: file.path,
          zipBytes: bytes,
        );
        state = state.copyWith(
          zipPreview: parsed,
          pickedFile: file,
          isParsing: false,
          clearProcessingFileName: true,
          clearProgressMessage: true,
        );
      } else {
        final bytes = await readPickedFileBytes(file);
        final parsed = const GpxWorkoutParser().parse(
          utf8.decode(bytes, allowMalformed: true),
        );
        state = state.copyWith(
          gpxPreview: parsed,
          pickedFile: file,
          isParsing: false,
          clearProcessingFileName: true,
          clearProgressMessage: true,
        );
      }
    } on OutOfMemoryError {
      state = state.copyWith(
        error:
            'This export is too large for available memory. '
            'Try exporting a shorter date range from the Health app.',
        isParsing: false,
        clearProcessingFileName: true,
        clearProgressMessage: true,
      );
    } on FormatException catch (e) {
      state = state.copyWith(
        error: e.message,
        isParsing: false,
        clearProcessingFileName: true,
        clearProgressMessage: true,
      );
    } on Object catch (e) {
      state = state.copyWith(
        error: 'Failed to parse file: $e',
        isParsing: false,
        clearProcessingFileName: true,
        clearProgressMessage: true,
      );
    }
  }

  Future<void> confirmImport() async {
    state = state.copyWith(
      isImporting: true,
      clearImportMessage: true,
      clearImportedWorkout: true,
      clearError: true,
    );

    final pickedFile = state.pickedFile;
    final isZip = pickedFile?.extension?.toLowerCase() == 'zip';

    String? error;
    String? importMessage;
    WorkoutSession? importedWorkout;
    var clearZipPreview = false;
    var clearPickedFile = false;

    if (pickedFile != null && (state.zipPreview != null || isZip)) {
      final result = await _importZip(pickedFile);
      error = result.error;
      importMessage = result.importMessage;
      clearZipPreview = result.cleared;
      clearPickedFile = result.cleared;
    } else if (state.gpxPreview != null) {
      final result = await _importGpx();
      error = result.error;
      importMessage = result.importMessage;
      importedWorkout = result.importedWorkout;
    }

    state = state.copyWith(
      isImporting: false,
      error: error,
      importMessage: importMessage,
      importedWorkout: importedWorkout,
      clearZipPreview: clearZipPreview,
      clearPickedFile: clearPickedFile,
      errorToken: error != null ? state.errorToken + 1 : state.errorToken,
    );
  }

  Future<({String? error, String? importMessage, WorkoutSession? importedWorkout})>
      _importGpx() async {
    final preview = state.gpxPreview;
    if (preview == null) {
      return (error: null, importMessage: null, importedWorkout: null);
    }

    final useCase = ref.read(importWorkoutUseCaseProvider);
    final result = await useCase(
      workout: preview.workout,
      routePoints: preview.routePoints,
    );

    if (result.failure != null) {
      return (
        error: result.failure!.message,
        importMessage: null,
        importedWorkout: null,
      );
    }

    invalidateHealthProviders(ref);

    return (
      error: null,
      importMessage: 'Run imported successfully.',
      importedWorkout: result.workout,
    );
  }

  Future<({String? error, String? importMessage, bool cleared})> _importZip(
    PlatformFile file,
  ) async {
    final preview = state.zipPreview;
    final bytes = preview == null && file.path == null
        ? await readPickedFileBytes(file)
        : null;
    final useCase = ref.read(importAppleHealthExportUseCaseProvider);
    final result = await useCase(
      parsed: preview,
      zipPath: preview == null ? file.path : null,
      zipBytes: bytes,
    );

    if (result.failure != null) {
      return (error: result.failure!.message, importMessage: null, cleared: false);
    }

    invalidateHealthProviders(ref);

    return (
      error: null,
      importMessage:
          'Imported ${result.importedDays} days of metrics and '
          '${result.importedWorkouts} runs.',
      cleared: true,
    );
  }
}
