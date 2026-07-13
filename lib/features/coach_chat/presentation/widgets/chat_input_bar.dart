import 'package:flutter/material.dart';
import 'package:kynos/core/theme/theme.dart';
import 'package:kynos/shared/widgets/glass_card.dart';
import 'package:kynos/shared/widgets/liquid_glass_button.dart';

class ChatInputBar extends StatelessWidget {
  const ChatInputBar({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.isStreaming,
    required this.onSend,
    this.onCancel,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isStreaming;
  final ValueChanged<String> onSend;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(Spacing.md),
        child: GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
          borderRadius: Radius.full,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  enabled: !isStreaming,
                  textInputAction: TextInputAction.send,
                  minLines: 1,
                  maxLines: 4,
                  keyboardType: TextInputType.multiline,
                  onSubmitted: isStreaming ? null : onSend,
                  decoration: const InputDecoration(
                    hintText: 'Ask your coach...',
                    border: InputBorder.none,
                  ),
                ),
              ),
              if (isStreaming && onCancel != null)
                TextButton(onPressed: onCancel, child: const Text('Stop')),
              LiquidGlassIconButton(
                icon: isStreaming ? Icons.hourglass_empty : Icons.send_rounded,
                tooltip: isStreaming ? 'Sending message' : 'Send message',
                onPressed: isStreaming ? null : () => onSend(controller.text),
                size: 36,
                iconSize: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
