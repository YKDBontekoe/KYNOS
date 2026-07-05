/// Strips sensitive fields from cloud-bound prompts.
abstract final class CloudPromptSanitizer {
  static String sanitize(String prompt) {
    var result = prompt;

    // GPS coordinates (lat/long decimal pairs).
    result = result.replaceAll(
      RegExp(r'-?\d{1,3}\.\d{4,},\s*-?\d{1,3}\.\d{4,}'),
      '[location-redacted]',
    );

    // ISO timestamps with timezone.
    result = result.replaceAll(
      RegExp(r'\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}[^,\s]*'),
      '[time-redacted]',
    );

    // UUIDs (workout ids).
    result = result.replaceAll(
      RegExp(
        r'[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-'
        r'[0-9a-fA-F]{4}-[0-9a-fA-F]{12}',
      ),
      '[id-redacted]',
    );

    return result;
  }
}
