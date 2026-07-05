import 'dart:isolate';

import 'package:kynos/infrastructure/health/import/apple_health_export_parser.dart';

/// Parses Apple Health zip bytes off the UI isolate.
Future<AppleHealthExportParseResult> parseAppleHealthZipAsync(
  List<int> zipBytes,
) {
  return Isolate.run(() => parseAppleHealthZipBytes(zipBytes));
}

/// Top-level entry point for [Isolate.run].
AppleHealthExportParseResult parseAppleHealthZipBytes(List<int> zipBytes) {
  return const AppleHealthExportParser().parseZip(zipBytes);
}
