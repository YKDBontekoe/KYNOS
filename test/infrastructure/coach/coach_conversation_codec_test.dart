import 'package:flutter_test/flutter_test.dart';
import 'package:kynos/domain/entities/chat_message.dart';
import 'package:kynos/domain/entities/coach/coach_conversation.dart';
import 'package:kynos/domain/entities/health/health_coach_models.dart';
import 'package:kynos/domain/entities/health/health_metric.dart';
import 'package:kynos/domain/entities/health/health_visual_artifact.dart';
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

  test('round-trips the exact structured artifact snapshot', () {
    final date = DateTime(2026, 7, 13);
    final artifact = HealthVisualArtifact.trend(
      meta: HealthArtifactMeta(
        id: 'trend-1',
        title: 'Restoration trend',
        explanation: 'Seven valid nights.',
        start: date.subtract(const Duration(days: 6)),
        end: date,
        confidence: FindingConfidence.moderate,
        limitations: const ['One night is missing.'],
      ),
      series: [
        HealthSeries(
          id: 'sleep',
          label: 'Sleep',
          metric: HealthMetric.sleep,
          unit: 'h',
          points: [HealthDataPoint(date: date, value: 7.2)],
        ),
      ],
    );
    final conversation = CoachConversation(
      id: 'thread-1',
      title: 'Sleep pattern',
      createdAt: date,
      updatedAt: date,
      messages: [
        ChatMessage(
          id: 'message-1',
          role: MessageRole.assistant,
          content: 'Your recent sleep is shown below.',
          timestamp: date,
          visualArtifacts: [artifact],
        ),
      ],
    );

    final decoded = CoachConversationCodec.decodeThread(
      CoachConversationCodec.encodeThread(conversation),
    );

    expect(decoded, isNotNull);
    expect(decoded!.messages.single.visualArtifacts, [artifact]);
  });

  test('keeps a legacy message while skipping a malformed artifact', () {
    const raw = '''
{
  "id": "thread-1",
  "title": "Legacy",
  "createdAt": "2026-07-13T10:00:00.000",
  "updatedAt": "2026-07-13T10:00:00.000",
  "settings": {},
  "messages": [{
    "id": "message-1",
    "role": "assistant",
    "content": "Still readable",
    "timestamp": "2026-07-13T10:00:00.000",
    "visualArtifacts": [{"type": "unknown"}]
  }]
}
''';

    final decoded = CoachConversationCodec.decodeThread(raw);

    expect(decoded, isNotNull);
    expect(decoded!.messages.single.content, 'Still readable');
    expect(decoded.messages.single.visualArtifacts, isNull);
  });
}
