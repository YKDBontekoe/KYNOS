import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kynos/domain/entities/chat_message.dart';
import 'package:kynos/features/coach_chat/presentation/widgets/animated_message_entrance.dart';
import 'package:kynos/features/coach_chat/presentation/widgets/message_list.dart';
import 'package:kynos/features/coach_chat/providers/coach_chat_provider.dart';

void main() {
  testWidgets('MessageList renders messages with entrance wrapper', (tester) async {
    final controller = ScrollController();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MessageList(
            messages: [
              ChatMessage(
                id: 'user_1',
                role: MessageRole.user,
                content: 'Hello coach',
                timestamp: DateTime(2026, 7, 5),
              ),
            ],
            scrollController: controller,
          ),
        ),
      ),
    );

    await tester.pump();

    expect(find.text('Hello coach'), findsOneWidget);
    expect(find.byType(AnimatedMessageEntrance), findsOneWidget);

    controller.dispose();
  });

  testWidgets('failed assistant message shows retry button', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: MessageBubble(
              message: ChatMessage(
                id: 'assistant_1',
                role: MessageRole.assistant,
                content: 'The on-device model hit a resource limit.',
                timestamp: DateTime(2026, 7, 5),
                hasError: true,
                userPromptForRetry: 'How is my recovery?',
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Retry'), findsOneWidget);
    expect(find.text('On-device error'), findsOneWidget);
  });

  testWidgets('tapping retry invokes coachChatProvider.retryMessage', (tester) async {
    final notifier = _RecordingCoachChatNotifier();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          coachChatProvider.overrideWith(() => notifier),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: MessageBubble(
              message: ChatMessage(
                id: 'assistant_1',
                role: MessageRole.assistant,
                content: 'The on-device model hit a resource limit.',
                timestamp: DateTime(2026, 7, 5),
                hasError: true,
                userPromptForRetry: 'How is my recovery?',
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Retry'));
    await tester.pump();

    expect(notifier.retriedAssistantId, 'assistant_1');
  });
}

class _RecordingCoachChatNotifier extends CoachChatNotifier {
  String? retriedAssistantId;

  @override
  Future<List<ChatMessage>> build() async => const [];

  @override
  Future<void> retryMessage(String assistantId) async {
    retriedAssistantId = assistantId;
  }
}
