import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:kynos/core/constants/imported_workout_ids.dart';
import 'package:kynos/domain/entities/health_summary.dart';
import 'package:kynos/domain/entities/workout_route_point.dart';
import 'package:kynos/domain/entities/workout_session.dart';
import 'package:kynos/infrastructure/health/import/apple_health_date_parser.dart';
import 'package:kynos/infrastructure/health/import/apple_health_record_aggregator.dart';
import 'package:kynos/infrastructure/health/import/apple_health_workout_builder.dart';
import 'package:kynos/infrastructure/health/import/gpx_workout_parser.dart';
import 'package:xml/xml_events.dart';

/// A running workout parsed from an Apple Health export.
class AppleHealthWorkoutImport {
  const AppleHealthWorkoutImport({
    required this.workout,
    this.routePoints = const [],
  });

  final WorkoutSession workout;
  final List<WorkoutRoutePoint> routePoints;
}

/// Result of parsing an Apple Health `export.zip` archive.
class AppleHealthExportParseResult {
  const AppleHealthExportParseResult({
    required this.summaries,
    required this.workouts,
    required this.recordCount,
    required this.skippedWorkouts,
  });

  final List<HealthSummary> summaries;
  final List<AppleHealthWorkoutImport> workouts;
  final int recordCount;
  final int skippedWorkouts;
}

/// Parses Apple Health `export.zip` into daily summaries and running workouts.
class AppleHealthExportParser {
  const AppleHealthExportParser({
    GpxWorkoutParser? gpxParser,
  }) : _gpxParser = gpxParser ?? const GpxWorkoutParser();

  final GpxWorkoutParser _gpxParser;

  AppleHealthExportParseResult parseZip(List<int> zipBytes) {
    final archive = ZipDecoder().decodeBytes(zipBytes);
    final files = _indexArchive(archive);

    final exportXml = _findExportXml(files);
    if (exportXml == null) {
      throw const FormatException(
        'Could not find export.xml inside the archive',
      );
    }

    return _parseExportXml(exportXml, files);
  }

  Map<String, List<int>> _indexArchive(Archive archive) {
    final files = <String, List<int>>{};
    for (final file in archive) {
      if (file.isFile) {
        files[_normalizePath(file.name)] = List<int>.from(file.content as List);
      }
    }
    return files;
  }

  String _normalizePath(String path) {
    return path.replaceAll('\\', '/').replaceFirst(RegExp(r'^\.?/'), '');
  }

  String? _findExportXml(Map<String, List<int>> files) {
    for (final entry in files.entries) {
      final name = entry.key.toLowerCase();
      if (name.endsWith('export.xml') && !name.endsWith('export_cda.xml')) {
        return utf8.decode(entry.value, allowMalformed: true);
      }
    }
    return null;
  }

  AppleHealthExportParseResult _parseExportXml(
    String rawXml,
    Map<String, List<int>> files,
  ) {
    final xml = sanitizeAppleHealthXml(rawXml);
    final aggregator = AppleHealthRecordAggregator();
    final workouts = <AppleHealthWorkoutImport>[];
    var recordCount = 0;
    var skippedWorkouts = 0;

    AppleHealthWorkoutBuilder? currentWorkout;
    var workoutDepth = 0;

    for (final event in parseEvents(xml, validateNesting: true)) {
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

    return AppleHealthExportParseResult(
      summaries: aggregator.finalize(),
      workouts: workouts,
      recordCount: recordCount,
      skippedWorkouts: skippedWorkouts,
    );
  }

  AppleHealthWorkoutImport? _finalizeWorkout(
    AppleHealthWorkoutBuilder builder,
    Map<String, List<int>> files,
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
      final gpxBytes = _lookupFile(files, path);
      if (gpxBytes == null) {
        continue;
      }

      try {
        final parsed = _gpxParser.parse(
          utf8.decode(gpxBytes, allowMalformed: true),
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

    return AppleHealthWorkoutImport(workout: workout, routePoints: routePoints);
  }

  String _stableWorkoutId(DateTime start, DateTime end) {
    return '${ImportedWorkoutIds.prefix}apple:${start.toUtc().millisecondsSinceEpoch}:${end.toUtc().millisecondsSinceEpoch}';
  }

  List<int>? _lookupFile(Map<String, List<int>> files, String path) {
    final normalized = _normalizePath(path);
    if (files.containsKey(normalized)) {
      return files[normalized];
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
