import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kynos/infrastructure/health/import/apple_health_export_parser.dart';
import 'package:kynos/infrastructure/health/import/apple_health_xml_event_stream.dart';
import 'package:xml/xml_events.dart';

void main() {
  group('streamAppleHealthXmlEvents', () {
    test('parses XML split across multiple chunks', () async {
      const xml = '''<?xml version="1.0" encoding="UTF-8"?>
<HealthData>
  <Record type="HKQuantityTypeIdentifierStepCount" unit="count" value="42"
    startDate="2026-04-20 08:00:00 +0000" endDate="2026-04-20 08:05:00 +0000"/>
</HealthData>''';

      final input = InputMemoryStream(utf8.encode(xml));
      final events = await streamAppleHealthXmlEvents(
        input,
        chunkSize: 16,
      ).toList();

      final recordStarts = events.whereType<XmlStartElementEvent>().where(
            (event) => event.name == 'Record',
          );
      expect(recordStarts, hasLength(1));
      expect(
        recordStarts.first.attributes.any(
          (attribute) =>
              attribute.name == 'value' && attribute.value == '42',
        ),
        isTrue,
      );
    });
  });

  group('AppleHealthExportParser.parseZipFile', () {
    test('parses export archives from disk', () async {
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

      final tempZip = await File(
        '${Directory.systemTemp.path}/apple_health_test_${DateTime.now().microsecondsSinceEpoch}.zip',
      ).writeAsBytes(ZipEncoder().encode(archive), flush: true);

      addTearDown(tempZip.delete);

      const parser = AppleHealthExportParser();
      final result = await parser.parseZipFile(tempZip.path);

      expect(result.recordCount, 4);
      expect(result.workouts, hasLength(1));
      expect(result.summaries.first.steps, 8421);
    });
  });
}
