import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:kynos/infrastructure/health/import/apple_health_date_parser.dart';
import 'package:xml/xml_events.dart';

/// Chunk size for streaming `export.xml` without loading the full file.
const int appleHealthXmlChunkSize = 256 * 1024;

/// Streams [XmlEvent]s from a decompressed Apple Health `export.xml` entry.
Stream<XmlEvent> streamAppleHealthXmlEvents(
  InputStream input, {
  int chunkSize = appleHealthXmlChunkSize,
}) async* {
  final eventBatches = _utf8ChunkStream(input, chunkSize: chunkSize)
      .map(sanitizeAppleHealthXmlChunk)
      .toXmlEvents(validateNesting: true);

  await for (final events in eventBatches) {
    for (final event in events) {
      yield event;
    }
  }
}

Stream<String> _utf8ChunkStream(
  InputStream input, {
  required int chunkSize,
}) async* {
  while (!input.isEOS && input.length > 0) {
    final count = input.length < chunkSize ? input.length : chunkSize;
    final chunk = input.readBytes(count);
    yield utf8.decode(chunk.toUint8List(), allowMalformed: true);
  }
}
