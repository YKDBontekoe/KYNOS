import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kynos/core/theme/theme.dart';
import 'package:kynos/shared/widgets/liquid_glass_surface.dart';

class ChatInputBar extends StatefulWidget {
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
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  bool _hasFocus = false;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_handleFocusChange);
    widget.controller.addListener(_handleTextChange);
    _hasText = widget.controller.text.trim().isNotEmpty;
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_handleFocusChange);
    widget.controller.removeListener(_handleTextChange);
    super.dispose();
  }

  void _handleFocusChange() {
    if (!mounted) return;
    setState(() => _hasFocus = widget.focusNode.hasFocus);
  }

  void _handleTextChange() {
    final hasText = widget.controller.text.trim().isNotEmpty;
    if (hasText == _hasText) return;
    setState(() => _hasText = hasText);
  }

  @override
  Widget build(BuildContext context) {
    final kynos = context.kynosTheme;
    final canSend = _hasText || widget.isStreaming;

    return Padding(
            padding: const EdgeInsets.fromLTRB(
              Spacing.md,
              Spacing.sm,
              Spacing.md,
              Spacing.sm,
            ),
      child: SizedBox(
        height: LayoutTokens.chatComposerExtent - Spacing.sm * 2,
        child: AnimatedContainer(
          duration: Motion.fast,
          curve: Motion.curve,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Radius.full),
            boxShadow: _hasFocus
                ? [
                    BoxShadow(
                      color: kynos.stand.withValues(alpha: 0.18),
                      blurRadius: 22,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : kynos.cardShadow,
          ),
          child: LiquidGlassSurface(
            borderRadius: Radius.full,
            blurSigma: LiquidGlassTokens.surfaceBlurSigma,
            border: Border.all(
              color: _hasFocus
                  ? kynos.stand.withValues(alpha: 0.55)
                  : LiquidGlassTokens.borderColor(
                      Theme.of(context).brightness,
                    ),
              width: _hasFocus ? 1.4 : 0.5,
            ),
            child: Padding(
              padding: const EdgeInsets.only(
                left: Spacing.md,
                right: Spacing.xs,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: widget.controller,
                      focusNode: widget.focusNode,
                      enabled: !widget.isStreaming,
                      textInputAction: TextInputAction.send,
                      minLines: 1,
                      maxLines: 3,
                      keyboardType: TextInputType.multiline,
                      onSubmitted: widget.isStreaming ? null : widget.onSend,
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(color: kynos.label),
                      cursorColor: kynos.stand,
                      decoration: InputDecoration(
                        hintText: 'Ask your coach…',
                        hintStyle: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(color: kynos.tertiaryLabel),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        filled: false,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: Spacing.sm,
                        ),
                      ),
                    ),
                  ),
                  if (widget.isStreaming && widget.onCancel != null)
                    Padding(
                      padding: const EdgeInsets.only(right: Spacing.xs),
                      child: TextButton(
                        onPressed: widget.onCancel,
                        style: TextButton.styleFrom(
                          foregroundColor: kynos.move,
                        ),
                        child: const Text('Stop'),
                      ),
                    ),
                  _SendButton(
                    isStreaming: widget.isStreaming,
                    canSend: canSend,
                    onPressed: widget.isStreaming
                        ? null
                        : () => widget.onSend(widget.controller.text),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Circular send button — solid accent when text is ready, muted glass otherwise.
class _SendButton extends StatelessWidget {
  const _SendButton({
    required this.isStreaming,
    required this.canSend,
    required this.onPressed,
  });

  final bool isStreaming;
  final bool canSend;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final kynos = context.kynosTheme;
    final icon = isStreaming
        ? Icons.hourglass_top_rounded
        : Icons.arrow_upward_rounded;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Spacing.xs),
      child: Semantics(
        button: true,
        label: isStreaming ? 'Sending message' : 'Send message',
        enabled: onPressed != null,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onPressed == null
                ? null
                : () {
                    HapticFeedback.lightImpact();
                    onPressed!();
                  },
            child: AnimatedContainer(
              duration: Motion.fast,
              curve: Motion.curve,
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: canSend
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [kynos.stand, kynos.purple],
                      )
                    : null,
                color: canSend ? null : kynos.separator.withValues(alpha: 0.6),
                boxShadow: canSend
                    ? [
                        BoxShadow(
                          color: kynos.stand.withValues(alpha: 0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                icon,
                size: 19,
                color: canSend ? KynosColors.onAccent : kynos.tertiaryLabel,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
