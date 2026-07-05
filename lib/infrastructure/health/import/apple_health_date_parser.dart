/// Parses timestamps from Apple Health `export.xml` attributes.
DateTime? parseAppleHealthDate(String? raw) {
  if (raw == null || raw.isEmpty) {
    return null;
  }

  // Apple uses "2016-04-02 10:40:38 +0100" — ISO 8601 needs a T separator.
  final normalized = raw.replaceFirst(' ', 'T');
  return DateTime.tryParse(normalized);
}

/// Strips control characters that break XML parsers in some exports.
String sanitizeAppleHealthXml(String input) {
  return input.replaceAll(RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F]'), '');
}
