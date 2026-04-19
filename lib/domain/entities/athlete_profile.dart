/// Immutable snapshot of an athlete's physiological profile.
///
/// All values are derived from on-device sensor data and never transmitted
/// to external servers (Zero-Knowledge Architecture).
class AthleteProfile {
  final String id;
  final String displayName;

  // Biomechanics baseline (updated by Nexus Lab after each run)
  final double? preferredCadenceSpm;    // steps per minute
  final double? biomechanicConstantB0;  // β₀ regression intercept
  final double? cadenceCoefficientB1;   // β₁ cadence weight
  final double? powerCoefficientB2;     // β₂ running-power weight

  // Training load metrics
  final double? acuteWorkload;   // 7-day ATL
  final double? chronicWorkload; // 28-day CTL
  double? get acwr =>
      (chronicWorkload != null && chronicWorkload! > 0)
          ? (acuteWorkload ?? 0) / chronicWorkload!
          : null;

  const AthleteProfile({
    required this.id,
    required this.displayName,
    this.preferredCadenceSpm,
    this.biomechanicConstantB0,
    this.cadenceCoefficientB1,
    this.powerCoefficientB2,
    this.acuteWorkload,
    this.chronicWorkload,
  });

  AthleteProfile copyWith({
    String? displayName,
    double? preferredCadenceSpm,
    double? biomechanicConstantB0,
    double? cadenceCoefficientB1,
    double? powerCoefficientB2,
    double? acuteWorkload,
    double? chronicWorkload,
  }) =>
      AthleteProfile(
        id: id,
        displayName: displayName ?? this.displayName,
        preferredCadenceSpm: preferredCadenceSpm ?? this.preferredCadenceSpm,
        biomechanicConstantB0:
            biomechanicConstantB0 ?? this.biomechanicConstantB0,
        cadenceCoefficientB1:
            cadenceCoefficientB1 ?? this.cadenceCoefficientB1,
        powerCoefficientB2: powerCoefficientB2 ?? this.powerCoefficientB2,
        acuteWorkload: acuteWorkload ?? this.acuteWorkload,
        chronicWorkload: chronicWorkload ?? this.chronicWorkload,
      );
}
