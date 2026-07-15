/// Per-conversation inference routing preference.
enum CoachBackendMode {
  auto('Auto'),
  onDevice('On-device'),
  cloud('Cloud');

  const CoachBackendMode(this.label);
  final String label;
}
