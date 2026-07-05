import 'package:flutter_test/flutter_test.dart';
import 'package:kynos/domain/entities/health_summary.dart';
import 'package:kynos/infrastructure/ai/gemma/ai_isolate_messages.dart';
import 'package:kynos/infrastructure/ai/gemma/coach_prompt_builder.dart';

void main() {
  group('buildCoachUserMessage', () {
    test('returns user message unchanged when health context is absent', () {
      expect(buildCoachUserMessage('How is my cadence?', null), 'How is my cadence?');
      expect(buildCoachUserMessage('How is my cadence?', []), 'How is my cadence?');
    });

    test('prepends health metrics without system instruction', () {
      final prompt = buildCoachUserMessage(
        'Should I run today?',
        [
          HealthSummary(
            date: DateTime(2026, 7, 5),
            rhrBpm: 52,
            hrvMs: 68,
            sleepHours: 7.5,
            distanceMeters: 28000,
          ),
        ],
      );

      expect(prompt, contains('Recent athlete metrics:'));
      expect(prompt, contains('Athlete question: Should I run today?'));
      expect(prompt, isNot(contains('KYNOS Coach')));
      expect(prompt, isNot(contains('Never reveal you are an AI model')));
    });
  });

  group('AiIsolateResponse types', () {
    test('chunk carries token text', () {
      final chunk = AiIsolateChunk('hello');
      expect(chunk.chunk, 'hello');
    });

    test('regression result carries coefficients', () {
      final result = AiTrainRegressionResult(b0: 1, b1: 2, b2: 3);
      expect(result.b0, 1);
      expect(result.b1, 2);
      expect(result.b2, 3);
    });
  });
}
