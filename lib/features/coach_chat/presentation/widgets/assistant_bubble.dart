import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:kynos/core/theme/theme.dart';
import 'package:kynos/domain/entities/ai_inference_backend.dart';
import 'package:kynos/domain/entities/coach/coach_tool_call.dart';
import 'package:kynos/features/coach_chat/presentation/widgets/agent_tool_step_list.dart';
import 'package:kynos/features/coach_chat/presentation/widgets/coach_markdown_text.dart';
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

  String? get _errorLabel {
    if (!hasError) return null;
    return switch (attemptedBackend) {
      AiInferenceBackend.openRouter => 'Cloud error',
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
    ).textTheme.bodyLarge?.copyWith(height: 1.5, color: kynos.label);

    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.92,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.xs,
            vertical: Spacing.xs,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.auto_awesome_rounded,
                    size: 14,
                    color: kynos.purple,
                  ),
                  const Gap(Spacing.xs),
                  Text(
                    'KYNOS Coach',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: kynos.secondaryLabel,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const Gap(Spacing.xs),
              if (_errorLabel != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: Spacing.sm),
                  child: KynosChip.accent(
                    label: _errorLabel!,
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              if (toolSteps != null && toolSteps!.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(bottom: Spacing.sm),
                  padding: const EdgeInsets.all(Spacing.sm),
                  decoration: BoxDecoration(
                    color: kynos.purple.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(Radius.md),
                  ),
                  child: AgentToolStepList(steps: toolSteps!),
                ),
              isStreaming && content.isEmpty
                  ? const TypingIndicator()
                  : StreamingTextPulse(
                      isActive: isStreaming && content.isNotEmpty,
                      child: CoachMarkdownText(text: content, style: textStyle),
                    ),
              if (!isStreaming &&
                  contextSnapshotIds != null &&
                  contextSnapshotIds!.isNotEmpty) ...[
                const Gap(Spacing.sm),
                Text(
                  'Answered using: ${contextSnapshotIds!.join(', ')}',
                  style: Theme.of(
                    context,
                  ).textTheme.labelSmall?.copyWith(color: kynos.secondaryLabel),
                ),
              ],
              if (hasError &&
                  (onRetry != null || onTryAlternateBackend != null)) ...[
                const Gap(Spacing.sm),
                Wrap(
                  spacing: Spacing.sm,
                  runSpacing: Spacing.xs,
                  children: [
                    if (onRetry != null)
                      TextButton.icon(
                        onPressed: onRetry,
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: const Text('Retry'),
                      ),
                    if (onTryAlternateBackend != null &&
                        alternateBackendLabel != null)
                      TextButton.icon(
                        onPressed: onTryAlternateBackend,
                        icon: Icon(
                          alternateBackend == AiInferenceBackend.openRouter
                              ? Icons.cloud_outlined
                              : Icons.memory_rounded,
                          size: 18,
                        ),
                        label: Text(alternateBackendLabel!),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
