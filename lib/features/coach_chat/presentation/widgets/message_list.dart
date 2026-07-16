import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:kynos/app/router.dart';
import 'package:kynos/core/theme/theme.dart';
import 'package:kynos/domain/entities/ai_inference_backend.dart';
import 'package:kynos/domain/entities/chat_message.dart';
import 'package:kynos/domain/entities/coach/today_directive.dart';
import 'package:kynos/domain/entities/coach/training_plan.dart';
import 'package:kynos/domain/entities/health/health_coach_models.dart';
import 'package:kynos/domain/usecases/coach/build_proactive_health_agent_run_usecase.dart';
import 'package:kynos/domain/utils/readiness_score.dart';
import 'package:kynos/features/coach_chat/presentation/widgets/animated_message_entrance.dart';
import 'package:kynos/features/coach_chat/presentation/widgets/assistant_bubble.dart';
import 'package:kynos/features/coach_chat/presentation/widgets/daily_health_brief_card.dart';
import 'package:kynos/features/coach_chat/presentation/widgets/health_check_in_sheet.dart';
import 'package:kynos/features/coach_chat/presentation/widgets/pending_coach_action_card.dart';
import 'package:kynos/features/coach_chat/presentation/widgets/proactive_health_agent_card.dart';
import 'package:kynos/features/coach_chat/presentation/widgets/today_directive_card.dart';
import 'package:kynos/features/coach_chat/providers/coach_chat_provider.dart';
import 'package:kynos/features/coach_chat/providers/proactive_health_agent_provider.dart';
import 'package:kynos/shared/providers/ai_repository_providers.dart';
import 'package:kynos/shared/providers/health_coach_providers.dart';
import 'package:kynos/shared/providers/health_providers.dart';
import 'package:kynos/shared/providers/plan_health_sync_provider.dart';
import 'package:kynos/shared/providers/training_plan_providers.dart';
import 'package:kynos/shared/providers/weekly_adaptation_provider.dart';
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
      AiInferenceBackend.cloud =>
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
      AiInferenceBackend.cloud => 'Try on-device',
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
        AiInferenceBackend.cloud,
      AiInferenceBackend.cloud => AiInferenceBackend.onDevice,
      _ => null,
    };
  }
}

class CoachChatEmptyState extends ConsumerWidget {
  const CoachChatEmptyState({super.key, required this.onSuggestionTap});

  final ValueChanged<String> onSuggestionTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Keep plan sync (auto-adherence + post-run debrief) subscribed on coach home.
    ref.watch(planHealthSyncProvider);
    final brief = ref.watch(dailyHealthBriefProvider);
    final summary = ref.watch(healthSummaryProvider);
    final coachData = ref.watch(healthCoachDataProvider).value;
    final directive = ref.watch(todayDirectiveProvider);
    final accountability = ref.watch(coachAccountabilityProvider);
    final plan = ref.watch(trainingPlanDataProvider).value;
    final weeklyAdapt = ref.watch(weeklyAdaptationProvider);
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

    final suggestions = _emptyStateSuggestions(
      directive: directive,
      accountability: accountability,
      plan: plan,
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        Spacing.md,
        Spacing.lg,
        Spacing.md,
        LayoutTokens.chatListBottomPadding,
      ),
      children: [
        Text(
          'Today’s session',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: -0.6,
              ),
        ),
        const Gap(Spacing.xs),
        Text(
          readinessLine ??
              'Own the day — confirm the session, or ask why it matters.',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: kynos.secondaryLabel,
              ),
        ),
        const Gap(Spacing.lg),
        TodayDirectiveCard(
          directive: directive,
          onAsk: (prompt) {
            if (accountability.morningBriefDue) {
              ref
                  .read(coachAccountabilityProvider.notifier)
                  .markMorningBriefShown();
            }
            onSuggestionTap(prompt);
          },
        ),
        if (plan != null) ...[
          const Gap(Spacing.sm),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => context.push(Routes.plan),
              icon: const Icon(Icons.calendar_view_week_rounded, size: 18),
              label: const Text('View this week'),
            ),
          ),
        ],
        if (weeklyAdapt != null) ...[
          const Gap(Spacing.md),
          PendingCoachActionCard(action: weeklyAdapt),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () =>
                  ref.read(weeklyAdaptationProvider.notifier).dismiss(),
              child: const Text('Not now'),
            ),
          ),
        ],
        const Gap(Spacing.md),
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
        const Gap(Spacing.md),
        ref.watch(proactiveHealthAgentRunsProvider).when(
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
              data: (runs) {
                final visible = runs
                    .where(
                      (r) =>
                          r.kind != ProactiveHealthAgentKind.morningPulse,
                    )
                    .toList();
                if (visible.isEmpty) return const SizedBox.shrink();
                return Column(
                  children: [
                    for (final run in visible) ...[
                      ProactiveHealthAgentCard(
                        run: run,
                        onAsk: onSuggestionTap,
                      ),
                      const Gap(Spacing.md),
                    ],
                  ],
                );
              },
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
        for (final suggestion in suggestions) ...[
          _CoachPrompt(
            label: suggestion,
            onTap: () {
              if (accountability.morningBriefDue) {
                ref
                    .read(coachAccountabilityProvider.notifier)
                    .markMorningBriefShown();
              }
              onSuggestionTap(suggestion);
            },
          ),
          const Gap(Spacing.sm),
        ],
      ],
    );
  }

  List<String> _emptyStateSuggestions({
    required TodayDirective directive,
    required CoachAccountabilityState accountability,
    required TrainingPlan? plan,
  }) {
    final suggestions = <String>[];
    if (accountability.morningBriefDue) {
      suggestions.add(
        'Morning brief: what should I lock in for today?',
      );
    }
    if (accountability.yesterdaySkipped) {
      suggestions.add(
        'I skipped yesterday — how do we protect the week?',
      );
    }
    suggestions.add(directive.promptSeed);
    if (directive.source != TodayDirectiveSource.buildPlanCta) {
      suggestions.add('Why is today’s session prescribed this way?');
    }
    if (plan != null) {
      suggestions.add('How is my week tracking against the plan?');
    } else if (!suggestions.contains(
      'Build my multi-week training plan based on my goals.',
    )) {
      suggestions.add('Build my multi-week training plan based on my goals.');
    }
    return suggestions.take(4).toList(growable: false);
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
