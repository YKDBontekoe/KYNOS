import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kynos/domain/entities/ai_inference_backend.dart';
import 'package:kynos/domain/entities/chat_message.dart';
import 'package:kynos/features/coach_chat/presentation/widgets/animated_message_entrance.dart';
import 'package:kynos/features/coach_chat/presentation/widgets/message_list.dart';
import 'package:kynos/features/coach_chat/providers/coach_chat_provider.dart';
import 'package:kynos/shared/providers/ai_repository_providers.dart';

void main() {
  testWidgets('MessageList renders messages with entrance wrapper', (tester) async {
    final controller = ScrollController();

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
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
      ),
    );

    await tester.pump();

    expect(find.text('Hello coach'), findsOneWidget);
    expect(find.byType(AnimatedMessageEntrance), findsOneWidget);

    controller.dispose();
  });

  testWidgets('successful on-device assistant message does not show error chip', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: MessageBubble(
              message: ChatMessage(
                id: 'assistant_ok',
                role: MessageRole.assistant,
                content: 'Your recovery is showing some fluctuation.',
                timestamp: DateTime(2026, 7, 5),
                hasError: false,
                attemptedBackend: AiInferenceBackend.onDevice,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('On-device error'), findsNothing);
    expect(find.text('Your recovery is showing some fluctuation.'), findsOneWidget);
  });

  testWidgets('failed assistant message shows retry and cloud switch', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          isCloudCoachConfiguredProvider.overrideWith((ref) async => true),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: MessageBubble(
              message: ChatMessage(
                id: 'assistant_1',
                role: MessageRole.assistant,
                content: 'The on-device model used too many resources on this device.',
                timestamp: DateTime(2026, 7, 5),
                hasError: true,
                userPromptForRetry: 'How is my recovery?',
                attemptedBackend: AiInferenceBackend.onDevice,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Retry'), findsOneWidget);
    expect(find.text('Try cloud coach'), findsOneWidget);
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
                attemptedBackend: AiInferenceBackend.onDevice,
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

  testWidgets('tapping try cloud invokes retryWithAlternateBackend', (tester) async {
    final notifier = _RecordingCoachChatNotifier();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          coachChatProvider.overrideWith(() => notifier),
          isCloudCoachConfiguredProvider.overrideWith((ref) async => true),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: MessageBubble(
              message: ChatMessage(
                id: 'assistant_1',
                role: MessageRole.assistant,
                content: 'The on-device model used too many resources.',
                timestamp: DateTime(2026, 7, 5),
                hasError: true,
                userPromptForRetry: 'How is my recovery?',
                attemptedBackend: AiInferenceBackend.onDevice,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Try cloud coach'));
    await tester.pump();

    expect(notifier.alternateRetriedAssistantId, 'assistant_1');
  });
}

class _RecordingCoachChatNotifier extends CoachChatNotifier {
  String? retriedAssistantId;
  String? alternateRetriedAssistantId;

  @override
  Future<List<ChatMessage>> build() async => const [];

  @override
  Future<void> retryMessage(String assistantId) async {
    retriedAssistantId = assistantId;
  }

  @override
  Future<void> retryWithAlternateBackend(String assistantId) async {
    alternateRetriedAssistantId = assistantId;
  }
}
