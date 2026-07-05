import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kynos/infrastructure/health/import/apple_health_export_parser.dart';

void main() {
  group('AppleHealthExportParser', () {
    late List<int> zipBytes;

    setUp(() async {
      final xml = await File('test/fixtures/apple_health_export.xml')
          .readAsString();
      final gpx =
          await File('test/fixtures/sample_run.gpx').readAsString();

      final archive = Archive()
        ..addFile(
          ArchiveFile(
            'apple_health_export/export.xml',
            xml.length,
            xml.codeUnits,
          ),
        )
        ..addFile(
          ArchiveFile(
            'apple_health_export/workout-routes/route_2026-04-20.gpx',
            gpx.length,
            gpx.codeUnits,
          ),
        );

      zipBytes = ZipEncoder().encode(archive)!;
    });

    test('parses metrics, summaries, and running workouts with routes', () {
      const parser = AppleHealthExportParser();
      final result = parser.parseZip(zipBytes);

      expect(result.recordCount, 4);
      expect(result.summaries, isNotEmpty);
      expect(result.workouts, hasLength(1));

      final summary = result.summaries.first;
      expect(summary.steps, 8421);
      expect(summary.hrvMs, 62);
      expect(summary.activeCalories, greaterThan(0));
      expect(summary.sleepHours, closeTo(7.5, 0.1));

      final workout = result.workouts.first.workout;
      expect(workout.distanceMeters, closeTo(5200, 1));
      expect(workout.energyKcal, 310);
      expect(result.workouts.first.routePoints, isNotEmpty);
    });

    test('throws when export.xml is missing', () {
      const parser = AppleHealthExportParser();
      final emptyZip = ZipEncoder().encode(Archive())!;

      expect(
        () => parser.parseZip(emptyZip),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
