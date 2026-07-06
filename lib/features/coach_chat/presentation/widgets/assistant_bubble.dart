import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:kynos/core/theme/theme.dart';
import 'package:kynos/domain/entities/ai_inference_backend.dart';
import 'package:kynos/features/coach_chat/presentation/widgets/streaming_text_pulse.dart';
import 'package:kynos/features/coach_chat/presentation/widgets/typing_indicator.dart';
import 'package:kynos/shared/widgets/glass_card.dart';
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
  });

  final String content;
  final bool isStreaming;
  final bool hasError;
  final AiInferenceBackend? attemptedBackend;
  final VoidCallback? onRetry;
  final VoidCallback? onTryAlternateBackend;
  final AiInferenceBackend? alternateBackend;
  final String? alternateBackendLabel;

  Future<void> _copyMessage(BuildContext context) async {
    if (content.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: content));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Message copied')),
    );
  }

  String? get _errorLabel {
    if (!hasError) return null;
    return switch (attemptedBackend) {
      AiInferenceBackend.openRouter => 'Cloud error',
      AiInferenceBackend.onDevice || AiInferenceBackend.rulesOnly => 'On-device error',
      null => 'Coach error',
    };
  }

  @override
  Widget build(BuildContext context) {
    final kynos = context.kynosTheme;
    final textStyle = Theme.of(context).textTheme.bodyLarge?.copyWith(
          height: 1.5,
          color: kynos.label,
        );

    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.84),
        child: GlassCard(
          borderRadius: Radius.lg,
          padding: const EdgeInsets.symmetric(horizontal: Spacing.md, vertical: Spacing.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_errorLabel != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: Spacing.sm),
                  child: KynosChip.accent(
                    label: _errorLabel!,
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              isStreaming && content.isEmpty
                  ? const TypingIndicator()
                  : StreamingTextPulse(
                      isActive: isStreaming && content.isNotEmpty,
                      child: SelectableText(
                        content,
                        style: textStyle,
                        contextMenuBuilder: content.isEmpty
                            ? null
                            : (menuContext, editableTextState) {
                                final items =
                                    editableTextState.contextMenuButtonItems;
                                return AdaptiveTextSelectionToolbar.buttonItems(
                                  anchors: editableTextState.contextMenuAnchors,
                                  buttonItems: [
                                    ...items,
                                    ContextMenuButtonItem(
                                      onPressed: () {
                                        ContextMenuController.removeAny();
                                        _copyMessage(menuContext);
                                      },
                                      label: 'Copy message',
                                    ),
                                  ],
                                );
                              },
                      ),
                    ),
              if (hasError && (onRetry != null || onTryAlternateBackend != null)) ...[
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
                    if (onTryAlternateBackend != null && alternateBackendLabel != null)
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
