import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:kynos/core/constants/imported_workout_ids.dart';
import 'package:kynos/domain/entities/workout_route_point.dart';
import 'package:kynos/domain/entities/workout_session.dart';
import 'package:kynos/domain/usecases/health/apple_health_export_parser.dart'
    as domain;

import 'package:kynos/infrastructure/health/import/apple_health_record_aggregator.dart';
import 'package:kynos/infrastructure/health/import/apple_health_workout_builder.dart';
import 'package:kynos/infrastructure/health/import/apple_health_xml_event_stream.dart';
import 'package:kynos/infrastructure/health/import/gpx_workout_parser.dart';
import 'package:xml/xml_events.dart';

typedef AppleHealthExportParseResult = domain.AppleHealthExportParseResult;
typedef AppleHealthWorkoutImport = domain.AppleHealthWorkoutImport;

/// Parses Apple Health `export.zip` into daily summaries and running workouts.
///
/// Uses streaming I/O so large `export.xml` files do not need to fit fully in
/// memory. On native platforms prefer [parseZipFile] with a file path.
class AppleHealthExportParser implements domain.AppleHealthExportParser {
  const AppleHealthExportParser({
    GpxWorkoutParser? gpxParser,
  }) : _gpxParser = gpxParser ?? const GpxWorkoutParser();

  final GpxWorkoutParser _gpxParser;

  @override
  Future<domain.AppleHealthExportParseResult> parse({
    List<int>? zipBytes,
    String? zipPath,
  }) {
    if (zipPath != null && zipPath.isNotEmpty) {
      return parseZipFile(zipPath);
    }
    if (zipBytes != null) {
      return parseZip(zipBytes);
    }
    throw ArgumentError('Either zipPath or zipBytes must be provided.');
  }

  /// Parses a zip archive from an on-disk path without loading the zip bytes.
  Future<domain.AppleHealthExportParseResult> parseZipFile(
    String zipPath,
  ) async {
    final input = InputFileStream(zipPath);
    try {
      final archive = ZipDecoder().decodeStream(input);
      return _parseArchive(archive);
    } finally {
      input.closeSync();
    }
  }

  /// Parses a zip archive held in memory (web and tests).
  Future<domain.AppleHealthExportParseResult> parseZip(
    List<int> zipBytes,
  ) async {
    final input = InputMemoryStream(zipBytes);
    final archive = ZipDecoder().decodeStream(input);
    return _parseArchive(archive);
  }

  Future<domain.AppleHealthExportParseResult> _parseArchive(
    Archive archive,
  ) async {
    final files = _indexArchive(archive);
    final exportXmlFile = _findExportXmlFile(files);
    if (exportXmlFile == null) {
      throw const FormatException(
        'Could not find export.xml inside the archive',
      );
    }

    return _parseExportXmlStream(exportXmlFile, files);
  }

  Map<String, ArchiveFile> _indexArchive(Archive archive) {
    final files = <String, ArchiveFile>{};
    for (final file in archive) {
      if (file.isFile) {
        files[_normalizePath(file.name)] = file;
      }
    }
    return files;
  }

  String _normalizePath(String path) {
    return path.replaceAll('\\', '/').replaceFirst(RegExp(r'^\.?/'), '');
  }

  ArchiveFile? _findExportXmlFile(Map<String, ArchiveFile> files) {
    for (final entry in files.entries) {
      final name = entry.key.toLowerCase();
      if (name.endsWith('export.xml') && !name.endsWith('export_cda.xml')) {
        return entry.value;
      }
    }
    return null;
  }

  Future<domain.AppleHealthExportParseResult> _parseExportXmlStream(
    ArchiveFile exportXmlFile,
    Map<String, ArchiveFile> files,
  ) async {
    final content = exportXmlFile.getContent();
    if (content == null) {
      throw const FormatException('Could not read export.xml from the archive');
    }

    try {
      return await _consumeXmlEvents(
        streamAppleHealthXmlEvents(content),
        files,
      );
    } finally {
      content.closeSync();
      exportXmlFile.clear();
    }
  }

  Future<domain.AppleHealthExportParseResult> _consumeXmlEvents(
    Stream<XmlEvent> events,
    Map<String, ArchiveFile> files,
  ) async {
    final aggregator = AppleHealthRecordAggregator();
    final workouts = <domain.AppleHealthWorkoutImport>[];
    var recordCount = 0;
    var skippedWorkouts = 0;

    AppleHealthWorkoutBuilder? currentWorkout;
    var workoutDepth = 0;

    await for (final event in events) {
      if (event is XmlStartElementEvent) {
        switch (event.name) {
          case 'Record':
            recordCount += 1;
            aggregator.addRecord(
              type: xmlEventAttr(event, 'type') ?? '',
              value: xmlEventAttr(event, 'value'),
              unit: xmlEventAttr(event, 'unit'),
              startDate: xmlEventAttr(event, 'startDate') ?? '',
              endDate: xmlEventAttr(event, 'endDate') ?? '',
            );
          case 'ActivitySummary':
            aggregator.addActivitySummary(
              dateComponents: xmlEventAttr(event, 'dateComponents') ?? '',
              activeEnergyBurned: xmlEventAttr(event, 'activeEnergyBurned'),
              activeEnergyBurnedUnit:
                  xmlEventAttr(event, 'activeEnergyBurnedUnit'),
              appleExerciseTime: xmlEventAttr(event, 'appleExerciseTime'),
            );
          case 'Workout':
            workoutDepth += 1;
            if (workoutDepth == 1) {
              currentWorkout = AppleHealthWorkoutBuilder.fromAttributes(event);
            }
          case 'FileReference':
            if (currentWorkout != null && workoutDepth > 0) {
              final path = xmlEventAttr(event, 'path');
              if (path != null) {
                currentWorkout.routePaths.add(path);
              }
            }
        }
      } else if (event is XmlEndElementEvent && event.name == 'Workout') {
        if (workoutDepth == 1 && currentWorkout != null) {
          final import = _finalizeWorkout(currentWorkout, files);
          if (import != null) {
            workouts.add(import);
          } else {
            skippedWorkouts += 1;
          }
          currentWorkout = null;
        }
        workoutDepth = (workoutDepth - 1).clamp(0, workoutDepth);
      }
    }

    return domain.AppleHealthExportParseResult(
      summaries: aggregator.finalize(),
      workouts: workouts,
      recordCount: recordCount,
      skippedWorkouts: skippedWorkouts,
    );
  }

  domain.AppleHealthWorkoutImport? _finalizeWorkout(
    AppleHealthWorkoutBuilder builder,
    Map<String, ArchiveFile> files,
  ) {
    if (!builder.isRunning) {
      return null;
    }

    final start = builder.start;
    final end = builder.end;
    if (start == null || end == null || !end.isAfter(start)) {
      return null;
    }

    var distanceMeters = builder.distanceMeters;
    var routePoints = const <WorkoutRoutePoint>[];

    for (final path in builder.routePaths) {
      final gpxText = _readArchiveFileAsString(files, path);
      if (gpxText == null) {
        continue;
      }

      try {
        final parsed = _gpxParser.parse(
          gpxText,
          sourceName: builder.sourceName ?? 'Apple Health',
        );
        routePoints = parsed.routePoints;
        if ((distanceMeters ?? 0) <= 0) {
          distanceMeters = parsed.workout.distanceMeters;
        }
        break;
      } on FormatException {
        continue;
      }
    }

    if ((distanceMeters ?? 0) <= 0) {
      return null;
    }

    final workout = WorkoutSession(
      id: _stableWorkoutId(start, end),
      start: start,
      end: end,
      workoutType: 'running',
      distanceMeters: distanceMeters,
      energyKcal: builder.energyKcal,
      sourceName: builder.sourceName ?? 'Apple Health',
      startLatitude: routePoints.isEmpty ? null : routePoints.first.latitude,
      startLongitude: routePoints.isEmpty ? null : routePoints.first.longitude,
      endLatitude: routePoints.isEmpty ? null : routePoints.last.latitude,
      endLongitude: routePoints.isEmpty ? null : routePoints.last.longitude,
    );

    return domain.AppleHealthWorkoutImport(
      workout: workout,
      routePoints: routePoints,
    );
  }

  String _stableWorkoutId(DateTime start, DateTime end) {
    return '${ImportedWorkoutIds.prefix}apple:${start.toUtc().millisecondsSinceEpoch}:${end.toUtc().millisecondsSinceEpoch}';
  }

  String? _readArchiveFileAsString(Map<String, ArchiveFile> files, String path) {
    final file = _lookupArchiveFile(files, path);
    if (file == null) {
      return null;
    }

    try {
      final bytes = file.readBytes();
      if (bytes == null || bytes.isEmpty) {
        return null;
      }
      return utf8.decode(bytes, allowMalformed: true);
    } finally {
      file.clear();
    }
  }

  ArchiveFile? _lookupArchiveFile(Map<String, ArchiveFile> files, String path) {
    final normalized = _normalizePath(path);
    final direct = files[normalized];
    if (direct != null) {
      return direct;
    }

    final lower = normalized.toLowerCase();
    for (final entry in files.entries) {
      if (entry.key.toLowerCase() == lower) {
        return entry.value;
      }
    }

    final fileName = normalized.split('/').last;
    for (final entry in files.entries) {
      if (entry.key.toLowerCase().endsWith('/$fileName') ||
          entry.key.toLowerCase() == fileName.toLowerCase()) {
        return entry.value;
      }
    }

    return null;
  }
}
