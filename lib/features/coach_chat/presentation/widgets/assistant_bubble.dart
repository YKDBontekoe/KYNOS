import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:kynos/core/theme/theme.dart';
import 'package:kynos/features/coach_chat/presentation/widgets/typing_indicator.dart';
import 'package:kynos/shared/widgets/glass_card.dart';
import 'package:kynos/shared/widgets/kynos_chip.dart';

class AssistantBubble extends StatelessWidget {
  const AssistantBubble({
    super.key,
    required this.content,
    required this.isStreaming,
    this.hasError = false,
    this.onRetry,
  });

  final String content;
  final bool isStreaming;
  final bool hasError;
  final VoidCallback? onRetry;

  Future<void> _copyMessage(BuildContext context) async {
    if (content.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: content));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Message copied')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.84),
        child: GestureDetector(
          onLongPress: content.isEmpty ? null : () => _copyMessage(context),
          child: GlassCard(
            borderRadius: Radius.lg,
            padding: const EdgeInsets.symmetric(horizontal: Spacing.md, vertical: Spacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (hasError)
                  Padding(
                    padding: const EdgeInsets.only(bottom: Spacing.sm),
                    child: KynosChip.accent(
                      label: 'On-device error',
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                isStreaming && content.isEmpty
                    ? const TypingIndicator()
                    : SelectableText(
                        content,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              height: 1.5,
                              color: hasError
                                  ? Theme.of(context).colorScheme.error
                                  : null,
                            ),
                      ),
                if (hasError && onRetry != null) ...[
                  const Gap(Spacing.sm),
                  TextButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('Retry'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
