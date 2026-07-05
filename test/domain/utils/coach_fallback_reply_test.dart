import 'package:flutter_test/flutter_test.dart';
import 'package:kynos/domain/entities/health_summary.dart';
import 'package:kynos/domain/utils/coach_fallback_reply.dart';

void main() {
  group('CoachFallbackReply', () {
    test('returns recovery-focused fallback for recovery questions', () {
      final reply = CoachFallbackReply.forRecoveryQuestion(
        userMessage: 'How is my recovery?',
        healthContext: [
          HealthSummary(
            date: DateTime(2026, 7, 5),
            hrvMs: 55,
            sleepHours: 7.5,
          ),
        ],
      );

      expect(reply, contains('on-device model'));
      expect(reply.toLowerCase(), contains('readiness'));
    });
  });
}
