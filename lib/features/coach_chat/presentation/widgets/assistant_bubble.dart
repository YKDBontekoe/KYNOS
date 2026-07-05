import 'package:flutter/material.dart';
import 'package:kynos/core/theme/theme.dart';
import 'package:kynos/features/coach_chat/presentation/widgets/typing_indicator.dart';
import 'package:kynos/shared/widgets/glass_card.dart';

class AssistantBubble extends StatelessWidget {
  const AssistantBubble({
    super.key,
    required this.content,
    required this.isStreaming,
  });

  final String content;
  final bool isStreaming;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.84),
        child: GlassCard(
          borderRadius: Radius.lg,
          padding: const EdgeInsets.symmetric(horizontal: Spacing.md, vertical: Spacing.sm),
          child: isStreaming && content.isEmpty
              ? const TypingIndicator()
              : Text(
                  content,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        height: 1.5,
                      ),
                ),
        ),
      ),
    );
  }
}
