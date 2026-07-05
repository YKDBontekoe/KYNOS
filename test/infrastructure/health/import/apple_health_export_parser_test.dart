import 'dart:convert';
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
            utf8.encode(xml).length,
            utf8.encode(xml),
          ),
        )
        ..addFile(
          ArchiveFile(
            'apple_health_export/workout-routes/route_2026-04-20.gpx',
            utf8.encode(gpx).length,
            utf8.encode(gpx),
          ),
        );

      zipBytes = ZipEncoder().encode(archive);
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
      expect(workout.sourceName, 'Apple Watch');
      expect(result.workouts.first.routePoints, isNotEmpty);
    });

    test('preserves non-ASCII metadata in export.xml', () {
      const parser = AppleHealthExportParser();
      final xml = utf8.encode(
        '''<?xml version="1.0" encoding="UTF-8"?>
<HealthData locale="en_US">
  <Record type="HKQuantityTypeIdentifierStepCount" unit="count" value="10"
    sourceName="Café Watch" startDate="2026-04-20 08:00:00 +0000"
    endDate="2026-04-20 08:05:00 +0000"/>
</HealthData>''',
      );
      final archive = Archive()
        ..addFile(ArchiveFile('export.xml', xml.length, xml));
      final result = parser.parseZip(ZipEncoder().encode(archive));

      expect(result.summaries.first.steps, 10);
    });

    test('throws when export.xml is missing', () {
      const parser = AppleHealthExportParser();
      final emptyZip = ZipEncoder().encode(Archive());

      expect(
        () => parser.parseZip(emptyZip),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
