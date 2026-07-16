import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:kynos/core/theme/spacing.dart' as tokens;
import 'package:kynos/core/theme/theme.dart' hide Radius;
import 'package:kynos/domain/entities/ai_inference_backend.dart';
import 'package:kynos/domain/entities/coach/coach_tool_call.dart';
import 'package:kynos/domain/entities/health/health_coach_models.dart';
import 'package:kynos/domain/entities/health/health_visual_artifact.dart';
import 'package:kynos/features/coach_chat/presentation/widgets/agent_tool_step_list.dart';
import 'package:kynos/features/coach_chat/presentation/widgets/coach_markdown_text.dart';
import 'package:kynos/features/coach_chat/presentation/widgets/health_visual_artifact_card.dart';
import 'package:kynos/features/coach_chat/presentation/widgets/pending_coach_action_card.dart';
import 'package:kynos/features/coach_chat/presentation/widgets/streaming_text_pulse.dart';
import 'package:kynos/features/coach_chat/presentation/widgets/typing_indicator.dart';
import 'package:kynos/shared/widgets/kynos_chip.dart';

class AssistantBubble extends StatelessWidget {
  const AssistantBubble({
    super.key,
    required this.content,
    required this.isStreaming,
    this.hasError = false,
    this.attemptedBackend,
    this.onRetry,
    this.onTryAlternateBackend,
    this.alternateBackend,
    this.alternateBackendLabel,
    this.contextSnapshotIds,
    this.toolSteps,
    this.visualArtifacts,
    this.pendingActions,
    this.onExploreArtifact,
  });

  final String content;
  final bool isStreaming;
  final bool hasError;
  final AiInferenceBackend? attemptedBackend;
  final VoidCallback? onRetry;
  final VoidCallback? onTryAlternateBackend;
  final AiInferenceBackend? alternateBackend;
  final String? alternateBackendLabel;
  final List<String>? contextSnapshotIds;
  final List<CoachToolStep>? toolSteps;
  final List<HealthVisualArtifact>? visualArtifacts;
  final List<PendingCoachAction>? pendingActions;
  final ValueChanged<String>? onExploreArtifact;

  String? get _errorLabel {
    if (!hasError) return null;
    return switch (attemptedBackend) {
      AiInferenceBackend.cloud => 'Cloud error',
      AiInferenceBackend.onDevice ||
      AiInferenceBackend.rulesOnly => 'On-device error',
      null => 'Coach error',
    };
  }

  @override
  Widget build(BuildContext context) {
    final kynos = context.kynosTheme;
    final textStyle = Theme.of(
      context,
    ).textTheme.bodyLarge?.copyWith(height: 1.48, color: kynos.label);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.86,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: Spacing.xs),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  left: Spacing.xs,
                  bottom: Spacing.xs,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            kynos.purple,
                            kynos.purple.withValues(alpha: 0.6),
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.auto_awesome_rounded,
                        size: 12,
                        color: KynosColors.onAccent,
                      ),
                    ),
                    const Gap(Spacing.xs),
                    Text(
                      'KYNOS Coach',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: kynos.secondaryLabel,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.1,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(Spacing.md),
                decoration: BoxDecoration(
                  color: hasError
                      ? kynos.move.withValues(alpha: isDark ? 0.10 : 0.06)
                      : kynos.card,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(18),
                    bottomLeft: Radius.circular(18),
                    bottomRight: Radius.circular(18),
                  ),
                  border: hasError
                      ? Border.all(
                          color: kynos.move.withValues(alpha: 0.25),
                        )
                      : null,
                  boxShadow: hasError ? null : kynos.cardShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_errorLabel != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: Spacing.sm),
                        child: KynosChip.accent(
                          label: _errorLabel!,
                          color: kynos.move,
                        ),
                      ),
                    if (toolSteps != null && toolSteps!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: Spacing.sm),
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(
                            Spacing.sm,
                            Spacing.sm,
                            Spacing.sm,
                            0,
                          ),
                          decoration: BoxDecoration(
                            color: kynos.purple.withValues(alpha: 0.07),
                            borderRadius: BorderRadius.circular(tokens.Radius.md),
                          ),
                          child: AgentToolStepList(steps: toolSteps!),
                        ),
                      ),
                    isStreaming && content.isEmpty
                        ? const TypingIndicator()
                        : StreamingTextPulse(
                            isActive: isStreaming && content.isNotEmpty,
                            child: CoachMarkdownText(
                              text: content,
                              style: textStyle,
                            ),
                          ),
                    if (!isStreaming &&
                        visualArtifacts != null &&
                        visualArtifacts!.isNotEmpty) ...[
                      const Gap(Spacing.md),
                      for (final artifact in visualArtifacts!) ...[
                        HealthVisualArtifactCard(
                          artifact: artifact,
                          onExplore: onExploreArtifact ?? (_) {},
                        ),
                        const Gap(Spacing.sm),
                      ],
                    ],
                    if (!isStreaming &&
                        pendingActions != null &&
                        pendingActions!.isNotEmpty) ...[
                      const Gap(Spacing.sm),
                      for (final action in pendingActions!) ...[
                        PendingCoachActionCard(action: action),
                        const Gap(Spacing.sm),
                      ],
                    ],
                    if (!isStreaming &&
                        contextSnapshotIds != null &&
                        contextSnapshotIds!.isNotEmpty) ...[
                      const Gap(Spacing.sm),
                      Text(
                        'Answered using: ${contextSnapshotIds!.join(', ')}',
                        style: Theme.of(context).textTheme.labelSmall
                            ?.copyWith(color: kynos.secondaryLabel),
                      ),
                    ],
                    if (hasError &&
                        (onRetry != null ||
                            onTryAlternateBackend != null)) ...[
                      const Gap(Spacing.sm),
                      Wrap(
                        spacing: Spacing.sm,
                        runSpacing: Spacing.xs,
                        children: [
                          if (onRetry != null)
                            _PillActionButton(
                              icon: Icons.refresh_rounded,
                              label: 'Retry',
                              color: kynos.move,
                              onTap: onRetry!,
                            ),
                          if (onTryAlternateBackend != null &&
                              alternateBackendLabel != null)
                            _PillActionButton(
                              icon:
                                  alternateBackend ==
                                      AiInferenceBackend.cloud
                                  ? Icons.cloud_outlined
                                  : Icons.memory_rounded,
                              label: alternateBackendLabel!,
                              color: kynos.stand,
                              onTap: onTryAlternateBackend!,
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PillActionButton extends StatelessWidget {
  const _PillActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.10),
      borderRadius: BorderRadius.circular(tokens.Radius.full),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(tokens.Radius.full),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.sm,
            vertical: Spacing.xs,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 15, color: color),
              const Gap(Spacing.xs),
              Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
