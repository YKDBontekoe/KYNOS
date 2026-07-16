/// Preset and helpers for OpenAI-compatible cloud LLM endpoints.
abstract final class CloudLlmEndpoint {
  /// Default OpenRouter OpenAI-compatible base URL (kept as a one-click preset).
  static const openRouterBaseUrl = 'https://openrouter.ai/api/v1';

  /// Common OpenAI-compatible presets shown in Settings.
  static const List<({String label, String baseUrl})> presets = [
    (label: 'OpenRouter', baseUrl: openRouterBaseUrl),
    (label: 'OpenAI', baseUrl: 'https://api.openai.com/v1'),
    (label: 'Groq', baseUrl: 'https://api.groq.com/openai/v1'),
  ];

  /// True when [baseUrl] targets OpenRouter (enables the models catalog UI).
  static bool isOpenRouter(String? baseUrl) {
    if (baseUrl == null || baseUrl.isEmpty) return true;
    final normalized = normalizeBaseUrl(baseUrl).toLowerCase();
    return normalized.contains('openrouter.ai');
  }

  /// Trims trailing slashes so `/chat/completions` joins cleanly.
  static String normalizeBaseUrl(String baseUrl) {
    var url = baseUrl.trim();
    while (url.endsWith('/')) {
      url = url.substring(0, url.length - 1);
    }
    return url;
  }
}
