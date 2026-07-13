import 'package:flutter_test/flutter_test.dart';
import 'package:kynos/domain/utils/coach_prompt_truncator.dart';
import 'package:kynos/domain/utils/gemma_inference_limits.dart';

void main() {
  group('truncateCoachPrompt', () {
    test('returns prompt unchanged when under limit', () {
      const prompt = 'Private wellbeing context:\nReadiness: 50/100\n\n'
          'Person’s question: How am I doing?';
      expect(truncateCoachPrompt(prompt), prompt);
    });

    test('preserves question block when truncating long context', () {
      final context = 'x' * 3000;
      final prompt = '$context\n\nPerson’s question: Summarize my health data';
      final truncated = truncateCoachPrompt(prompt);

      expect(truncated, contains('Person’s question: Summarize my health data'));
      expect(truncated.length, lessThanOrEqualTo(GemmaInferenceLimits.maxPromptCharacters));
      expect(truncated.startsWith('x'), isTrue);
    });
  });

  group('coachResponseLooksTruncated', () {
    test('detects mid-sentence cutoff near output budget', () {
      final longIncomplete = 'Your readiness is low because ' * 30;
      expect(
        coachResponseLooksTruncated(
          longIncomplete,
          maxOutputTokens: 256,
        ),
        isTrue,
      );
    });

    test('returns false for complete sentences', () {
      expect(
        coachResponseLooksTruncated(
          'Your readiness is low. Rest today and try an easy walk tomorrow.',
          maxOutputTokens: 256,
        ),
        isFalse,
      );
    });
  });
}
