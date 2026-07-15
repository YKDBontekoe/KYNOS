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
import 'package:kynos/features/coach_chat/presentation/widgets/health_check_in_sheet.dart';
import 'package:kynos/features/coach_chat/providers/coach_chat_provider.dart';
import 'package:kynos/shared/providers/ai_repository_providers.dart';
import 'package:kynos/shared/providers/health_coach_providers.dart';
import 'package:kynos/shared/providers/health_providers.dart';
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

    Future<void> openCheckIn() async {
      final result = await showModalBottomSheet<HealthCheckIn>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (_) => HealthCheckInSheet(initial: todayCheckIn),
      );
      if (result == null) return;
      await ref.read(healthCoachDataProvider.notifier).saveCheckIn(result);
      ref.invalidate(dailyHealthBriefProvider);
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        Spacing.md,
        Spacing.lg,
        Spacing.md,
        LayoutTokens.chatListBottomPadding,
      ),
      children: [
        Text(
          'How can I help?',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: -0.6,
              ),
        ),
        const Gap(Spacing.xs),
        Text(
          readinessLine ?? 'Ask about your recovery, training, or next run.',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: kynos.secondaryLabel,
              ),
        ),
        const Gap(Spacing.lg),
        brief.when(
          loading: () => const KynosLoadingLine(
            label: 'Preparing today’s coaching note…',
          ),
          error: (_, _) => const SizedBox.shrink(),
          data: (value) => DailyHealthBriefCard(
            brief: value,
            onCheckIn: openCheckIn,
            checkInLabel: todayCheckIn == null ? 'Check in' : 'Update',
          ),
        ),
        const Gap(Spacing.lg),
        Text(
          'Try asking',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: kynos.secondaryLabel,
                fontWeight: FontWeight.w600,
              ),
        ),
        const Gap(Spacing.sm),
        for (final suggestion in const [
          'What should I do today?',
          'Why has my energy changed?',
          'Compare this week with last week',
        ]) ...[
          _CoachPrompt(
            label: suggestion,
            onTap: () => onSuggestionTap(suggestion),
          ),
          const Gap(Spacing.sm),
        ],
      ],
    );
  }
}

class _CoachPrompt extends StatelessWidget {
  const _CoachPrompt({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final kynos = context.kynosTheme;

    return Material(
      color: kynos.card.withValues(alpha: 0.72),
      borderRadius: BorderRadius.circular(Radius.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Radius.md),
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.md,
            vertical: Spacing.sm,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Radius.md),
            border: Border.all(
              color: kynos.separator.withValues(alpha: 0.55),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
              Icon(
                Icons.arrow_upward_rounded,
                size: 17,
                color: kynos.tertiaryLabel,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
