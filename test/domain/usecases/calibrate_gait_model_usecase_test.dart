import 'package:flutter_test/flutter_test.dart';
import 'package:kynos/core/errors/failures.dart';
import 'package:kynos/domain/entities/health_summary.dart';
import 'package:kynos/domain/repositories/biomechanics_repository.dart';
import 'package:kynos/domain/repositories/health_repository.dart';
import 'package:kynos/domain/usecases/nexus_lab/calibrate_gait_model_usecase.dart';

void main() {
  group('CalibrateGaitModelUseCase', () {
    test(
      'returns calibration summary when steady-state samples are available',
      () async {
        final healthRepository = _FakeHealthRepository(
          summaries: <HealthSummary>[
            HealthSummary(
              date: DateTime(2026, 4, 1),
              cadenceSpm: 176,
              runningPowerWatts: 240,
              strideLengthMeters: 1.21,
              exerciseMinutes: 45,
            ),
            HealthSummary(
              date: DateTime(2026, 4, 2),
              cadenceSpm: 178,
              runningPowerWatts: 245,
              strideLengthMeters: 1.24,
              exerciseMinutes: 50,
            ),
            HealthSummary(
              date: DateTime(2026, 4, 3),
              cadenceSpm: 180,
              runningPowerWatts: 250,
              strideLengthMeters: 1.28,
              exerciseMinutes: 42,
            ),
          ],
        );
        final biomechanicsRepository = _FakeBiomechanicsRepository();

        final useCase = CalibrateGaitModelUseCase(
          healthRepository: healthRepository,
          biomechanicsRepository: biomechanicsRepository,
        );

        final result = await useCase();

        expect(result.failure, isNull);
        expect(result.sampleCount, 3);
        expect(result.calibrationSummary, isNotNull);
        expect(result.calibrationSummary, contains('Calibration Summary'));
        expect(biomechanicsRepository.saved, isTrue);
        expect(result.coefficients.b0, isNotNull);
        expect(result.coefficients.b1, isNotNull);
        expect(result.coefficients.b2, isNotNull);
      },
    );

    test('fails when insufficient steady-state samples exist', () async {
      final healthRepository = _FakeHealthRepository(
        summaries: <HealthSummary>[
          HealthSummary(
            date: DateTime(2026, 4, 1),
            cadenceSpm: 160,
            runningPowerWatts: 200,
            strideLengthMeters: 1.0,
            exerciseMinutes: 10,
          ),
        ],
      );
      final biomechanicsRepository = _FakeBiomechanicsRepository();

      final useCase = CalibrateGaitModelUseCase(
        healthRepository: healthRepository,
        biomechanicsRepository: biomechanicsRepository,
      );

      final result = await useCase();

      expect(result.failure, isA<BiomechanicsModelFailure>());
      expect(result.sampleCount, 0);
      expect(biomechanicsRepository.saved, isFalse);
    });
  });
}

class _FakeHealthRepository implements HealthRepository {
  _FakeHealthRepository({required List<HealthSummary> summaries})
    : _summaries = summaries;

  final List<HealthSummary> _summaries;

  @override
  Future<({List<HealthSummary> summaries, Failure? failure})> getSummaries({
    required int days,
  }) async {
    return (summaries: _summaries, failure: null);
  }

  @override
  Future<({HealthSummary? summary, Failure? failure})> getToday() async {
    return (
      summary: _summaries.isEmpty ? null : _summaries.first,
      failure: null,
    );
  }

  @override
  Future<bool> requestPermissions() async => true;
}

class _FakeBiomechanicsRepository implements BiomechanicsRepository {
  bool saved = false;

  double? _b0;
  double? _b1;
  double? _b2;

  @override
  ({double? b0, double? b1, double? b2}) get coefficients =>
      (b0: _b0, b1: _b1, b2: _b2);

  @override
  Future<({double? prediction, Failure? failure})> infer({
    required double cadenceSpm,
    required double powerWatts,
  }) async {
    return (prediction: 1.0, failure: null);
  }

  @override
  Future<Failure?> restore() async => null;

  @override
  Future<Failure?> save() async {
    saved = true;
    return null;
  }

  @override
  Future<Failure?> train(List<BiomechanicsSample> samples) async {
    _b0 = 0.2;
    _b1 = 0.004;
    _b2 = 0.001;
    return null;
  }
}
