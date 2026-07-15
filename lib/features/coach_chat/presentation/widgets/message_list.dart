import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:kynos/core/theme/theme.dart';
import 'package:kynos/domain/entities/ai_inference_backend.dart';
import 'package:kynos/domain/entities/chat_message.dart';
import 'package:kynos/domain/entities/health/health_coach_models.dart';
import 'package:kynos/domain/utils/readiness_score.dart';
import 'package:kynos/features/coach_chat/presentation/widgets/animated_message_entrance.dart';
import 'package:kynos/features/coach_chat/presentation/widgets/assistant_bubble.dart';
import 'package:kynos/features/coach_chat/presentation/widgets/daily_health_brief_card.dart';
import 'package:kynos/features/coach_chat/presentation/widgets/glass_suggestion_chip.dart';
import 'package:kynos/features/coach_chat/presentation/widgets/health_check_in_sheet.dart';
import 'package:kynos/features/coach_chat/providers/coach_chat_provider.dart';
import 'package:kynos/shared/providers/ai_repository_providers.dart';
import 'package:kynos/shared/providers/health_coach_providers.dart';
import 'package:kynos/shared/providers/health_providers.dart';
import 'package:kynos/shared/widgets/kynos_chip.dart';
import 'package:kynos/shared/widgets/kynos_loading_line.dart';
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
        LayoutTokens.chatListBottomPadding,
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
        visualArtifacts: message.visualArtifacts,
        pendingActions: message.pendingActions,
        onExploreArtifact: (prompt) =>
            ref.read(coachChatProvider.notifier).sendMessage(prompt),
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
    final brief = ref.watch(dailyHealthBriefProvider);
    final summary = ref.watch(healthSummaryProvider);
    final coachData = ref.watch(healthCoachDataProvider).value;
    final kynos = context.kynosTheme;
    final now = DateTime.now();
    final todayCheckIn = coachData?.checkIns
        .where(
          (item) =>
              item.date.year == now.year &&
              item.date.month == now.month &&
              item.date.day == now.day,
        )
        .firstOrNull;
    final readiness = readinessScore(summary.value);
    final readinessLine = readiness > 0
        ? readinessSummaryBrief(readiness).split('.').first
        : null;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        Spacing.md,
        Spacing.sm,
        Spacing.md,
        LayoutTokens.chatListBottomPadding,
      ),
      children: [
        if (readinessLine != null) ...[
          KynosChip.accent(
            label: readinessLine,
            color: kynos.purple,
          ),
          const Gap(Spacing.sm),
        ],
        brief.when(
          loading: () =>
              const KynosLoadingLine(label: 'Building your health brief…'),
          error: (_, _) => const SizedBox.shrink(),
          data: (value) => DailyHealthBriefCard(brief: value),
        ),
        const Gap(Spacing.sm),
        OutlinedButton.icon(
          onPressed: () async {
            final result = await showModalBottomSheet<HealthCheckIn>(
              context: context,
              isScrollControlled: true,
              showDragHandle: true,
              builder: (_) => HealthCheckInSheet(initial: todayCheckIn),
            );
            if (result == null) return;
            await ref
                .read(healthCoachDataProvider.notifier)
                .saveCheckIn(result);
            ref.invalidate(dailyHealthBriefProvider);
          },
          icon: Icon(
            todayCheckIn == null
                ? Icons.add_reaction_outlined
                : Icons.check_rounded,
          ),
          label: Text(
            todayCheckIn == null ? 'Check in now' : 'Update today’s check-in',
          ),
        ),
        const Gap(Spacing.xl),
        Text(
          'What would you like to understand?',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const Gap(Spacing.xs),
        Text(
          'Ask about patterns, trends, or what to do next.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: kynos.secondaryLabel,
              ),
        ),
        const Gap(Spacing.lg),
        Wrap(
          spacing: Spacing.sm,
          runSpacing: Spacing.sm,
          children: [
            'Why has my energy changed?',
            'Show my sleep trend',
            'Compare this week with last week',
            'What should I do today?',
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
    );
  }
}
