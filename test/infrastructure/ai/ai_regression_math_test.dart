import 'package:flutter_test/flutter_test.dart';
import 'package:kynos/infrastructure/ai/gemma/ai_isolate_messages.dart';
import 'package:kynos/infrastructure/ai/gemma/ai_regression_math.dart';

void main() {
  group('trainRegression', () {
    test('fits coefficients for three samples', () {
      const samples = [
        AiRegressionSample(
          cadenceSpm: 170,
          powerWatts: 200,
          strideLengthMeters: 1.1,
        ),
        AiRegressionSample(
          cadenceSpm: 180,
          powerWatts: 220,
          strideLengthMeters: 1.15,
        ),
        AiRegressionSample(
          cadenceSpm: 160,
          powerWatts: 180,
          strideLengthMeters: 1.05,
        ),
      ];

      final coefficients = trainRegression(samples);

      for (final sample in samples) {
        final predicted =
            coefficients.b0 +
            (coefficients.b1 * sample.cadenceSpm) +
            (coefficients.b2 * sample.powerWatts);
        expect(predicted, closeTo(sample.strideLengthMeters, 0.01));
      }
    });

    test('throws when fewer than three samples', () {
      expect(
        () => trainRegression(const [
          AiRegressionSample(
            cadenceSpm: 170,
            powerWatts: 200,
            strideLengthMeters: 1.1,
          ),
        ]),
        throwsStateError,
      );
    });
  });
}
