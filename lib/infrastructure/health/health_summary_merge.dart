/// Merges running workout metrics from two daily summaries without
/// double-counting the same run when HealthKit and imports overlap.
class HealthSummaryMerge {
  HealthSummaryMerge._();

  static const distanceToleranceMeters = 50.0;

  /// Combines running distance from two sources on the same day.
  ///
  /// When distances match within [distanceToleranceMeters], treats them as the
  /// same workout (e.g. HealthKit + GPX import). Otherwise sums distinct runs.
  static double? runningWorkoutDistanceMeters(double? a, double? b) {
    final av = a ?? 0;
    final bv = b ?? 0;
    if (av <= 0 && bv <= 0) return null;
    if (av <= 0) return b;
    if (bv <= 0) return a;
    if ((av - bv).abs() <= distanceToleranceMeters) {
      return av >= bv ? a : b;
    }
    return av + bv;
  }

  /// Combines run counts, deduplicating when distances overlap.
  static int? runningWorkoutCount({
    required int? a,
    required int? b,
    required double? distanceA,
    required double? distanceB,
  }) {
    final av = a ?? 0;
    final bv = b ?? 0;
    if (av <= 0 && bv <= 0) return null;
    if (av <= 0) return b;
    if (bv <= 0) return a;

    final dA = distanceA ?? 0;
    final dB = distanceB ?? 0;
    if (dA > 0 &&
        dB > 0 &&
        (dA - dB).abs() <= distanceToleranceMeters) {
      return av >= bv ? a : b;
    }
    return av + bv;
  }
}
