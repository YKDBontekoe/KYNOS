/// Where the last coach inference ran.
enum AiInferenceBackend {
  onDevice,

  /// Any OpenAI-compatible cloud endpoint (OpenRouter, OpenAI, Groq, etc.).
  cloud,

  rulesOnly,
}
