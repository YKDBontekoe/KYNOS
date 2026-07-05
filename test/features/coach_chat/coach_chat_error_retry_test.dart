import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kynos/domain/entities/chat_message.dart';
import 'package:kynos/features/coach_chat/presentation/widgets/message_list.dart';

void main() {
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
}
