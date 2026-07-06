import 'package:flutter_test/flutter_test.dart';
import 'package:kynos/infrastructure/coach/coach_conversation_codec.dart';

void main() {
  test('decodeLegacyMessages returns empty for null payload', () {
    expect(CoachConversationCodec.decodeLegacyMessages(null), isEmpty);
  });

  test('round-trips message context snapshot ids in thread codec', () {
    final raw = '''
[
  {
    "id": "a1",
    "role": "assistant",
    "content": "Hello",
    "timestamp": "2026-07-05T10:00:00.000",
    "contextSnapshotIds": ["readinessAcwr", "recentRuns"]
  }
]
''';
    final messages = CoachConversationCodec.decodeLegacyMessages(raw);
    expect(messages, hasLength(1));
    expect(messages.first.contextSnapshotIds, ['readinessAcwr', 'recentRuns']);
  });
}
