import 'package:kynos/core/errors/failures.dart';

/// Biomechanical sample used for on-device regression training.
class BiomechanicsSample {
  final double cadenceSpm;
  final double powerWatts;
  final double strideLengthMeters;
  final DateTime recordedAt;

  const BiomechanicsSample({
    required this.cadenceSpm,
    required this.powerWatts,
    required this.strideLengthMeters,
    required this.recordedAt,
  });
}

/// Contract for Nexus Lab — on-device biomechanics model training & inference.
///
/// Implements the multivariate linear regression:
///   ŷ = β₀ + β₁·cadence + β₂·power
abstract interface class BiomechanicsRepository {
  /// Trains the regression model incrementally with new [samples].
  Future<Failure?> train(List<BiomechanicsSample> samples);

  /// Predicts stride length for given [cadenceSpm] and [powerWatts].
  Future<({double? prediction, Failure? failure})> infer({
    required double cadenceSpm,
    required double powerWatts,
  });

  /// Persists the trained β-coefficients to local storage.
  Future<Failure?> save();

  /// Loads previously saved β-coefficients.
  Future<Failure?> restore();

  /// Returns current β-coefficients (null if model not yet trained).
  ({double? b0, double? b1, double? b2}) get coefficients;
}
