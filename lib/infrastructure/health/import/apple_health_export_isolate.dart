import 'dart:isolate';

import 'package:kynos/infrastructure/health/import/apple_health_export_parser.dart';

/// Parses Apple Health zip archives off the UI isolate.
///
/// Prefer [zipPath] on native platforms so the zip is read from disk instead of
/// being copied into memory twice (picker + isolate).
Future<AppleHealthExportParseResult> parseAppleHealthZipAsync({
  String? zipPath,
  List<int>? zipBytes,
}) {
  if (zipPath != null && zipPath.isNotEmpty) {
    return Isolate.run(() => parseAppleHealthZipFile(zipPath));
  }
  if (zipBytes != null) {
    return Isolate.run(() => parseAppleHealthZipBytes(zipBytes));
  }
  throw ArgumentError('Either zipPath or zipBytes must be provided.');
}

/// Top-level entry point for [Isolate.run] when parsing from a file path.
Future<AppleHealthExportParseResult> parseAppleHealthZipFile(String zipPath) {
  return const AppleHealthExportParser().parseZipFile(zipPath);
}

/// Top-level entry point for [Isolate.run] when parsing in-memory bytes.
Future<AppleHealthExportParseResult> parseAppleHealthZipBytes(List<int> zipBytes) {
  return const AppleHealthExportParser().parseZip(zipBytes);
}
