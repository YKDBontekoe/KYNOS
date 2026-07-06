import 'package:flutter_test/flutter_test.dart';
import 'package:kynos/domain/entities/health_summary.dart';
import 'package:kynos/domain/utils/coach_fallback_reply.dart';

void main() {
  group('CoachFallbackReply', () {
    final healthContext = [
      HealthSummary(
        date: DateTime(2026, 7, 5),
        hrvMs: 55,
        sleepHours: 7.5,
      ),
    ];

    test('returns recovery-focused fallback for recovery questions', () {
      final reply = CoachFallbackReply.forRecoveryQuestion(
        userMessage: 'How is my recovery?',
        healthContext: healthContext,
      );

      expect(reply, contains('could not reach the on-device model'));
      expect(reply.toLowerCase(), contains('readiness'));
    });

    test('returns generic fallback for unrelated questions', () {
      final reply = CoachFallbackReply.forRecoveryQuestion(
        userMessage: 'What should my cadence be?',
        healthContext: healthContext,
      );

      expect(reply, contains('coach model is unavailable right now'));
      expect(reply, isNot(contains('could not reach the on-device model')));
    });

    test('does not treat unrelated rest substring as recovery intent', () {
      final reply = CoachFallbackReply.forRecoveryQuestion(
        userMessage: 'What is the best interest rate for shoes?',
        healthContext: healthContext,
      );

      expect(reply, contains('coach model is unavailable right now'));
    });
  });
}
