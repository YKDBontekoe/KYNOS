import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kynos/core/theme/app_theme.dart';
import 'package:kynos/core/theme/kynos_theme_extension.dart';
import 'package:kynos/core/theme/spacing.dart' as tokens;
import 'package:kynos/domain/entities/chat_message.dart';
import 'package:kynos/features/coach_chat/providers/coach_chat_provider.dart';
import 'package:kynos/features/coach_chat/providers/model_setup_provider.dart';
import 'package:kynos/shared/widgets/glass_card.dart';
import 'package:kynos/shared/widgets/kynos_card.dart';
import 'package:kynos/shared/widgets/kynos_skeleton.dart';
import 'package:kynos/shared/widgets/kynos_user_bubble.dart';

// ── Page ──────────────────────────────────────────────────────────────────────

class CoachChatPage extends ConsumerStatefulWidget {
  const CoachChatPage({super.key});

  @override
  ConsumerState<CoachChatPage> createState() => _CoachChatPageState();
}

class _CoachChatPageState extends ConsumerState<CoachChatPage> {
  final _scrollController = ScrollController();
  final _textController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(modelSetupProvider.notifier).checkAndInstall();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

  void _handleSend([String? override]) {
    final text = (override ?? _textController.text).trim();
    if (text.isEmpty) return;
    _textController.clear();
    ref.read(coachChatProvider.notifier).sendMessage(text);
  }

  @override
  Widget build(BuildContext context) {
    final setupState = ref.watch(modelSetupProvider);

    return setupState.when(
      loading: () => _ModelSetupScreen.checking(),
      error: (e, _) => _ModelSetupScreen.error(
        message: e.toString(),
        onRetry: () => ref.read(modelSetupProvider.notifier).checkAndInstall(),
      ),
      data: (isReady) {
        if (!isReady) return _ModelSetupScreen.checking();
        return _buildChat();
      },
    );
  }

  Widget _buildChat() {
    ref.listen(
      coachChatProvider.select((s) => s.value?.lastOrNull?.content),
      (prev, next) => _scrollToBottom(),
    );

    final messages = ref.watch(coachChatProvider.select((s) => s.value ?? const []));
    final isStreaming = ref.watch(coachChatProvider.select((s) => s.value?.any((m) => m.isStreaming) ?? false));

    return Scaffold(
      backgroundColor: AppTheme.background,
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          _AppBar(
            onClear: () => ref.read(coachChatProvider.notifier).clearConversation(),
          ),
          Expanded(
            child: messages.isEmpty
                ? _EmptyState(onSuggestionTap: _handleSend)
                : _MessageList(messages: messages, scrollController: _scrollController),
          ),
          _InputBar(
            controller: _textController,
            focusNode: _focusNode,
            isStreaming: isStreaming,
            onSend: _handleSend,
          ),
        ],
      ),
    );
  }
}

// ── App bar ───────────────────────────────────────────────────────────────────

class _AppBar extends StatelessWidget {
  final VoidCallback onClear;

  const _AppBar({required this.onClear});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(tokens.Spacing.md, tokens.Spacing.xs, tokens.Spacing.md, tokens.Spacing.sm),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(color: AppTheme.exercise, shape: BoxShape.circle),
            ),
            const Gap(tokens.Spacing.sm),
            Text(
              'KYNOS Coach',
              style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w700, color: AppTheme.label),
            ),
            const Spacer(),
            _OnDeviceBadge(),
            const Gap(tokens.Spacing.sm),
            GestureDetector(
              onTap: onClear,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(color: AppTheme.separator, borderRadius: BorderRadius.circular(tokens.Radius.md)),
                child: const Icon(Icons.refresh_rounded, size: 18, color: AppTheme.secondaryLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnDeviceBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.exercise.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(tokens.Radius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.lock_rounded, size: 11, color: AppTheme.exercise),
          const Gap(tokens.Spacing.xs),
          Text(
            'On-Device',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppTheme.exercise,
                ),
          ),
        ],
      ),
    );
  }
}

// ── Message list ──────────────────────────────────────────────────────────────

class _MessageList extends StatelessWidget {
  final List<ChatMessage> messages;
  final ScrollController scrollController;

  const _MessageList({required this.messages, required this.scrollController});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(tokens.Spacing.md, tokens.Spacing.sm, tokens.Spacing.md, 96),
      itemCount: messages.length,
      itemBuilder: (context, index) => RepaintBoundary(
        child: Padding(
          padding: const EdgeInsets.only(bottom: tokens.Spacing.sm),
          child: _MessageBubble(message: messages[index]),
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return switch (message.role) {
      MessageRole.user => KynosUserBubble(text: message.content),
      MessageRole.assistant => _AssistantBubble(content: message.content, isStreaming: message.isStreaming),
    };
  }
}

class _AssistantBubble extends StatelessWidget {
  final String content;
  final bool isStreaming;

  const _AssistantBubble({required this.content, required this.isStreaming});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.84),
        child: GlassCard(
          borderRadius: tokens.Radius.lg,
          padding: const EdgeInsets.symmetric(horizontal: tokens.Spacing.md, vertical: tokens.Spacing.sm),
          child: isStreaming && content.isEmpty
              ? const _TypingIndicator()
              : Text(
                  content,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.label,
                        height: 1.5,
                      ),
                ),
        ),
      ),
    );
  }
}

class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();
  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat();
  @override
  void dispose() { _controller.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (i) => Padding(
          padding: EdgeInsets.only(left: i > 0 ? 6 : 0),
          child: Opacity(
            opacity: 0.25 + 0.75 * math.sin((_controller.value + i / 3.0) % 1.0 * math.pi).clamp(0.0, 1.0),
            child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppTheme.secondaryLabel, shape: BoxShape.circle)),
          ),
        )),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final ValueChanged<String> onSuggestionTap;
  const _EmptyState({required this.onSuggestionTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(tokens.Spacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline_rounded, size: 48, color: context.kynosTheme.stand),
            const Gap(tokens.Spacing.md),
            Text(
              'Your AI Coach',
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const Gap(tokens.Spacing.sm),
            Text(
              'Ask about training or recovery.\nAll analysis runs on-device.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const Gap(tokens.Spacing.lg),
            for (final suggestion in [
              'How is my recovery?',
              'Am I ready for a workout?',
            ])
              Padding(
                padding: const EdgeInsets.symmetric(vertical: tokens.Spacing.xs),
                child: KynosCard(
                  onTap: () => onSuggestionTap(suggestion),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      suggestion,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isStreaming;
  final ValueChanged<String> onSend;

  const _InputBar({required this.controller, required this.focusNode, required this.isStreaming, required this.onSend});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(tokens.Spacing.md),
        child: GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: tokens.Spacing.md),
          borderRadius: tokens.Radius.full,
          child: Row(
            children: [
              Expanded(child: TextField(controller: controller, focusNode: focusNode, enabled: !isStreaming, decoration: const InputDecoration(hintText: 'Ask your coach...', border: InputBorder.none))),
              IconButton(icon: Icon(isStreaming ? Icons.hourglass_empty : Icons.send), onPressed: isStreaming ? null : () => onSend(controller.text)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModelSetupScreen extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final VoidCallback? onRetry;
  final bool isLoading;

  const _ModelSetupScreen({this.title, this.subtitle, this.onRetry, this.isLoading = false});

  factory _ModelSetupScreen.checking() => const _ModelSetupScreen(title: 'Preparing AI Coach', subtitle: 'Checking for model...', isLoading: true);
  factory _ModelSetupScreen.error({required String message, required VoidCallback onRetry}) => _ModelSetupScreen(title: 'Setup Failed', subtitle: message, onRetry: onRetry);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(tokens.Spacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isLoading)
                const KynosSkeleton(height: 48, width: 48)
              else
                Icon(Icons.error_outline, size: 48, color: context.kynosTheme.move),
              const Gap(tokens.Spacing.lg),
              Text(
                title ?? '',
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const Gap(tokens.Spacing.sm),
              Text(
                subtitle ?? '',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              if (onRetry != null) ...[
                const Gap(tokens.Spacing.lg),
                FilledButton(
                  onPressed: onRetry,
                  child: const Text('Try Again'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
