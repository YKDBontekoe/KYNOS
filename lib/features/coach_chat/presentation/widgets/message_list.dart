import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:kynos/core/theme/theme.dart';
import 'package:kynos/domain/entities/chat_message.dart';
import 'package:kynos/features/coach_chat/presentation/widgets/assistant_bubble.dart';
import 'package:kynos/features/coach_chat/providers/coach_chat_provider.dart';
import 'package:kynos/shared/widgets/kynos_card.dart';
import 'package:kynos/shared/widgets/kynos_user_bubble.dart';

class MessageList extends StatelessWidget {
  const MessageList({
    super.key,
    required this.messages,
    required this.scrollController,
  });

  final List<ChatMessage> messages;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(
        Spacing.md,
        Spacing.sm,
        Spacing.md,
        LayoutTokens.chatInputClearance,
      ),
      itemCount: messages.length,
      itemBuilder: (context, index) => RepaintBoundary(
        child: Padding(
          padding: const EdgeInsets.only(bottom: Spacing.sm),
          child: MessageBubble(message: messages[index]),
        ),
      ),
    );
  }
}

class MessageBubble extends ConsumerWidget {
  const MessageBubble({super.key, required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return switch (message.role) {
      MessageRole.user => KynosUserBubble(text: message.content),
      MessageRole.assistant => AssistantBubble(
          content: message.content,
          isStreaming: message.isStreaming,
          hasError: message.hasError,
          onRetry: message.hasError && message.userPromptForRetry != null
              ? () => ref
                  .read(coachChatProvider.notifier)
                  .retryMessage(message.id)
              : null,
        ),
    };
  }
}

class CoachChatEmptyState extends StatelessWidget {
  const CoachChatEmptyState({super.key, required this.onSuggestionTap});

  final ValueChanged<String> onSuggestionTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline_rounded, size: 48, color: context.kynosTheme.stand),
            const Gap(Spacing.md),
            Text(
              'Your AI Coach',
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const Gap(Spacing.sm),
            Text(
              'Ask about training or recovery.\nAll analysis runs on-device.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const Gap(Spacing.lg),
            for (final suggestion in [
              'How is my recovery?',
              'Am I ready for a workout?',
            ])
              Padding(
                padding: const EdgeInsets.symmetric(vertical: Spacing.xs),
                child: KynosCard(
                  onTap: () => onSuggestionTap(suggestion),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      suggestion,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
