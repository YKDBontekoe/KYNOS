import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kynos/core/theme/theme.dart';
import 'package:kynos/features/coach_chat/presentation/widgets/chat_input_bar.dart';
import 'package:kynos/features/coach_chat/presentation/widgets/coach_chat_app_bar.dart';
import 'package:kynos/features/coach_chat/presentation/widgets/message_list.dart';
import 'package:kynos/features/coach_chat/presentation/widgets/model_setup_screen.dart';
import 'package:kynos/features/coach_chat/providers/coach_chat_provider.dart';
import 'package:kynos/features/coach_chat/providers/model_setup_provider.dart';

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
      loading: () => ModelSetupScreen.checking(),
      error: (e, _) => ModelSetupScreen.error(
        message: e.toString(),
        onRetry: () => ref.read(modelSetupProvider.notifier).checkAndInstall(),
      ),
      data: (isReady) {
        if (!isReady) return ModelSetupScreen.checking();
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
    final isStreaming = ref.watch(
      coachChatProvider.select((s) => s.value?.any((m) => m.isStreaming) ?? false),
    );

    return Scaffold(
      backgroundColor: context.kynosTheme.background,
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          CoachChatAppBar(
            onClear: () => ref.read(coachChatProvider.notifier).clearConversation(),
          ),
          Expanded(
            child: messages.isEmpty
                ? CoachChatEmptyState(onSuggestionTap: _handleSend)
                : MessageList(messages: messages, scrollController: _scrollController),
          ),
          ChatInputBar(
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
