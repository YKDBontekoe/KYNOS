import 'package:flutter/material.dart';
import 'package:kynos/core/theme/theme.dart';
import 'package:kynos/shared/widgets/glass_card.dart';

class ChatInputBar extends StatelessWidget {
  const ChatInputBar({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.isStreaming,
    required this.onSend,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isStreaming;
  final ValueChanged<String> onSend;

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
                  decoration: const InputDecoration(
                    hintText: 'Ask your coach...',
                    border: InputBorder.none,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(isStreaming ? Icons.hourglass_empty : Icons.send),
                onPressed: isStreaming ? null : () => onSend(controller.text),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
