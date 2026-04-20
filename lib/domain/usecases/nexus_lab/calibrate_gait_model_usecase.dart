import 'package:kynos/core/errors/failures.dart';
import 'package:kynos/domain/entities/health_summary.dart';
import 'package:kynos/domain/repositories/biomechanics_repository.dart';
import 'package:kynos/domain/repositories/health_repository.dart';

/// Orchestrates continual-learning calibration for the on-device gait model.
class CalibrateGaitModelUseCase {
  const CalibrateGaitModelUseCase({
    required HealthRepository healthRepository,
    required BiomechanicsRepository biomechanicsRepository,
  }) : _healthRepository = healthRepository,
       _biomechanicsRepository = biomechanicsRepository;

  final HealthRepository _healthRepository;
  final BiomechanicsRepository _biomechanicsRepository;

  Future<
    ({
      String? calibrationSummary,
      int sampleCount,
      ({double? b0, double? b1, double? b2}) coefficients,
      Failure? failure,
    })
  >
  call({int lookbackDays = 30}) async {
    final healthResult = await _healthRepository.getSummaries(
      days: lookbackDays,
    );
    if (healthResult.failure != null) {
      return (
        calibrationSummary: null,
        sampleCount: 0,
        coefficients: _biomechanicsRepository.coefficients,
        failure: healthResult.failure,
      );
    }

    final samples = _extractSteadyStateSamples(healthResult.summaries);
    if (samples.length < 3) {
      return (
        calibrationSummary: null,
        sampleCount: samples.length,
        coefficients: _biomechanicsRepository.coefficients,
        failure: const BiomechanicsModelFailure(
          'Not enough steady-state data for calibration.',
        ),
      );
    }

    final before = _biomechanicsRepository.coefficients;

    final trainFailure = await _biomechanicsRepository.train(samples);
    if (trainFailure != null) {
      return (
        calibrationSummary: null,
        sampleCount: samples.length,
        coefficients: _biomechanicsRepository.coefficients,
        failure: trainFailure,
      );
    }

    final saveFailure = await _biomechanicsRepository.save();
    if (saveFailure != null) {
      return (
        calibrationSummary: null,
        sampleCount: samples.length,
        coefficients: _biomechanicsRepository.coefficients,
        failure: saveFailure,
      );
    }

    final after = _biomechanicsRepository.coefficients;

    return (
      calibrationSummary: _buildCalibrationSummary(
        before: before,
        after: after,
        sampleCount: samples.length,
      ),
      sampleCount: samples.length,
      coefficients: after,
      failure: null,
    );
  }

  List<BiomechanicsSample> _extractSteadyStateSamples(
    List<HealthSummary> summaries,
  ) {
    final tool = _SteadyStateExtractionTool();
    final samples = <BiomechanicsSample>[];

    for (final summary in summaries) {
      final sample = tool.extract(summary);
      if (sample != null) {
        samples.add(sample);
      }
    }

    return samples;
  }

  String _buildCalibrationSummary({
    required ({double? b0, double? b1, double? b2}) before,
    required ({double? b0, double? b1, double? b2}) after,
    required int sampleCount,
  }) {
    String formatChange(double? oldValue, double? newValue) {
      if (newValue == null) {
        return 'n/a';
      }
      if (oldValue == null) {
        return '${newValue.toStringAsFixed(6)} (new)';
      }
      final delta = newValue - oldValue;
      final sign = delta >= 0 ? '+' : '';
      return '${newValue.toStringAsFixed(6)} (${sign}${delta.toStringAsFixed(6)})';
    }

    return 'Calibration Summary\n'
        'Samples used: $sampleCount\n'
        'β0 (intercept): ${formatChange(before.b0, after.b0)}\n'
        'β1 (cadence): ${formatChange(before.b1, after.b1)}\n'
        'β2 (power): ${formatChange(before.b2, after.b2)}';
  }
}

/// Tool-style extractor used by the calibration use-case.
class _SteadyStateExtractionTool {
  BiomechanicsSample? extract(HealthSummary summary) {
    final cadence = summary.cadenceSpm;
    final power = summary.runningPowerWatts;
    final stride = summary.strideLengthMeters;
    final exerciseMinutes = summary.exerciseMinutes;

    if (cadence == null ||
        power == null ||
        stride == null ||
        exerciseMinutes == null) {
      return null;
    }

    // "Steady state" heuristic: sufficiently long aerobic window and plausible gait bounds.
    if (exerciseMinutes < 20) return null;
    if (cadence < 150 || cadence > 220) return null;
    if (power < 80 || power > 600) return null;
    if (stride < 0.5 || stride > 2.5) return null;

    return BiomechanicsSample(
      cadenceSpm: cadence,
      powerWatts: power,
      strideLengthMeters: stride,
      recordedAt: summary.date,
    );
  }
}
