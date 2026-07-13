import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:kynos/core/theme/theme.dart';
import 'package:kynos/domain/entities/ai_inference_backend.dart';
import 'package:kynos/domain/entities/chat_message.dart';
import 'package:kynos/features/coach_chat/presentation/widgets/animated_message_entrance.dart';
import 'package:kynos/features/coach_chat/presentation/widgets/assistant_bubble.dart';
import 'package:kynos/features/coach_chat/presentation/widgets/glass_suggestion_chip.dart';
import 'package:kynos/features/coach_chat/providers/coach_chat_provider.dart';
import 'package:kynos/shared/providers/ai_repository_providers.dart';
import 'package:kynos/shared/widgets/kynos_user_bubble.dart';

class MessageList extends StatefulWidget {
  const MessageList({
    super.key,
    required this.messages,
    required this.scrollController,
  });

  final List<ChatMessage> messages;
  final ScrollController scrollController;

  @override
  State<MessageList> createState() => _MessageListState();
}

class _MessageListState extends State<MessageList> {
  final _animatedMessageIds = <String>{};

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: widget.scrollController,
      padding: const EdgeInsets.fromLTRB(
        Spacing.md,
        Spacing.sm,
        Spacing.md,
        LayoutTokens.chatInputClearance,
      ),
      itemCount: widget.messages.length,
      itemBuilder: (context, index) {
        final message = widget.messages[index];
        final shouldAnimate = !_animatedMessageIds.contains(message.id);
        if (shouldAnimate) {
          _animatedMessageIds.add(message.id);
        }

        return RepaintBoundary(
          child: Padding(
            padding: const EdgeInsets.only(bottom: Spacing.sm),
            child: AnimatedMessageEntrance(
              fromRight: message.role == MessageRole.user,
              animate: shouldAnimate,
              child: MessageBubble(message: message),
            ),
          ),
        );
      },
    );
  }
}

class MessageBubble extends ConsumerWidget {
  const MessageBubble({super.key, required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cloudConfigured =
        ref.watch(isCloudCoachConfiguredProvider).value ?? false;

    return switch (message.role) {
      MessageRole.user => KynosUserBubble(text: message.content),
      MessageRole.assistant => AssistantBubble(
        content: message.content,
        isStreaming: message.isStreaming,
        hasError: message.hasError,
        attemptedBackend: message.attemptedBackend,
        contextSnapshotIds: message.contextSnapshotIds,
        toolSteps: message.toolSteps,
        onRetry: message.hasError && message.userPromptForRetry != null
            ? () =>
                  ref.read(coachChatProvider.notifier).retryMessage(message.id)
            : null,
        onTryAlternateBackend: _alternateBackendAction(
          ref: ref,
          message: message,
          cloudConfigured: cloudConfigured,
        ),
        alternateBackendLabel: _alternateBackendLabel(
          message: message,
          cloudConfigured: cloudConfigured,
        ),
        alternateBackend: _alternateBackend(
          message: message,
          cloudConfigured: cloudConfigured,
        ),
      ),
    };
  }

  VoidCallback? _alternateBackendAction({
    required WidgetRef ref,
    required ChatMessage message,
    required bool cloudConfigured,
  }) {
    if (!message.hasError || message.userPromptForRetry == null) return null;

    final alternate = switch (message.attemptedBackend) {
      AiInferenceBackend.onDevice || AiInferenceBackend.rulesOnly
          when cloudConfigured =>
        () => ref
            .read(coachChatProvider.notifier)
            .retryWithAlternateBackend(message.id),
      AiInferenceBackend.openRouter =>
        () => ref
            .read(coachChatProvider.notifier)
            .retryWithAlternateBackend(message.id),
      _ => null,
    };
    return alternate;
  }

  String? _alternateBackendLabel({
    required ChatMessage message,
    required bool cloudConfigured,
  }) {
    if (!message.hasError) return null;
    return switch (message.attemptedBackend) {
      AiInferenceBackend.onDevice ||
      AiInferenceBackend.rulesOnly when cloudConfigured => 'Try cloud coach',
      AiInferenceBackend.openRouter => 'Try on-device',
      _ => null,
    };
  }

  AiInferenceBackend? _alternateBackend({
    required ChatMessage message,
    required bool cloudConfigured,
  }) {
    if (!message.hasError) return null;
    return switch (message.attemptedBackend) {
      AiInferenceBackend.onDevice || AiInferenceBackend.rulesOnly
          when cloudConfigured =>
        AiInferenceBackend.openRouter,
      AiInferenceBackend.openRouter => AiInferenceBackend.onDevice,
      _ => null,
    };
  }
}

class CoachChatEmptyState extends ConsumerWidget {
  const CoachChatEmptyState({super.key, required this.onSuggestionTap});

  final ValueChanged<String> onSuggestionTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: context.kynosTheme.purple.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(Radius.lg),
              ),
              child: Icon(
                Icons.auto_awesome_rounded,
                color: context.kynosTheme.purple,
              ),
            ),
            const Gap(Spacing.md),
            Text(
              'What can I help you with?',
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const Gap(Spacing.sm),
            Text(
              'Ask about your recovery, recent runs, or what to do next.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const Gap(Spacing.lg),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: Spacing.sm,
              runSpacing: Spacing.sm,
              children:
                  [
                        'How is my recovery?',
                        'What should I train today?',
                        'How was my last run?',
                        'Help me plan this week',
                      ]
                      .map(
                        (suggestion) => GlassSuggestionChip(
                          label: suggestion,
                          onTap: () => onSuggestionTap(suggestion),
                        ),
                      )
                      .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
