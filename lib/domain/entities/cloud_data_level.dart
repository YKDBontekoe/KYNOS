/// How much health context may be included in OpenRouter prompts.
enum CloudDataLevel {
  none('None'),
  minimal('Minimal'),
  standard('Standard'),
  full('Full');

  const CloudDataLevel(this.label);
  final String label;
}
