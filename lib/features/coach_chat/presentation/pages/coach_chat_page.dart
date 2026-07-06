import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:kynos/app/router.dart';
import 'package:kynos/core/theme/theme.dart';
import 'package:kynos/domain/utils/ai_inference_error_policy.dart';
import 'package:kynos/features/coach_chat/presentation/widgets/chat_input_bar.dart';
import 'package:kynos/features/coach_chat/presentation/widgets/coach_chat_app_bar.dart';
import 'package:kynos/features/coach_chat/presentation/widgets/message_list.dart';
import 'package:kynos/features/coach_chat/presentation/widgets/model_setup_screen.dart';
import 'package:kynos/features/coach_chat/providers/coach_chat_provider.dart';
import 'package:kynos/features/coach_chat/providers/coach_chat_seed_provider.dart';
import 'package:kynos/features/coach_chat/providers/model_setup_provider.dart';
import 'package:kynos/features/coach_chat/providers/model_setup_state.dart';
import 'package:kynos/shared/providers/ai_reconnect_provider.dart';

class CoachChatPage extends ConsumerStatefulWidget {
  const CoachChatPage({super.key});

  @override
  ConsumerState<CoachChatPage> createState() => _CoachChatPageState();
}

class _CoachChatPageState extends ConsumerState<CoachChatPage> {
  final _scrollController = ScrollController();
  final _textController = TextEditingController();
  final _focusNode = FocusNode();
  bool _seedApplied = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(modelSetupProvider.notifier).checkAndInstall();
    });
  }

  void _applyCoachSeed() {
    if (!mounted || _seedApplied) return;
    final seed = ref.read(coachChatSeedProvider.notifier).consumeSeed();
    if (seed == null || seed.isEmpty) return;
    _seedApplied = true;
    _textController.text = seed;
    _focusNode.requestFocus();
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

  Future<void> _confirmClearConversation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear conversation?'),
        content: const Text(
          'This removes all messages in the current coach chat session.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    await ref.read(coachChatProvider.notifier).clearConversation();
  }

  String _setupErrorMessage(Object error) {
    if (error is MissingHuggingFaceTokenException) {
      return error.toString();
    }
    return AiInferenceErrorPolicy.userFriendlyMessage(error);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(aiReconnectStateProvider, (previous, next) {
      if (!next || !mounted) return;
      ref.read(aiReconnectStateProvider.notifier).clear();

      final setup = ref.read(modelSetupProvider);
      final setupBusy = setup.isLoading ||
          setup.value?.phase == ModelSetupPhase.checking ||
          setup.value?.phase == ModelSetupPhase.downloading;
      if (!setupBusy) {
        ref.read(modelSetupProvider.notifier).checkAndInstall();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reconnecting on-device coach…'),
          duration: Duration(seconds: 3),
        ),
      );
    });

    final setupState = ref.watch(modelSetupProvider);

    return setupState.when(
      loading: () => ModelSetupScreen.checking(),
      error: (e, _) {
        final missingToken = e is MissingHuggingFaceTokenException;
        return ModelSetupScreen.error(
          message: _setupErrorMessage(e),
          onRetry: () => ref.read(modelSetupProvider.notifier).checkAndInstall(),
          onSecondaryAction:
              missingToken ? () => context.push(Routes.settings) : null,
          secondaryActionLabel: missingToken ? 'Open Settings' : null,
        );
      },
      data: (setup) {
        if (!setup.isReady) {
          return ModelSetupScreen.checking(
            progressMessage: setup.progressMessage,
          );
        }
        WidgetsBinding.instance.addPostFrameCallback((_) => _applyCoachSeed());
        return _buildChat();
      },
    );
  }

  Widget _buildChat() {
    final chatState = ref.watch(coachChatProvider);

    ref.listen(
      coachChatProvider.select((s) => s.value?.lastOrNull?.content),
      (prev, next) => _scrollToBottom(),
    );

    if (chatState.hasError && !chatState.isLoading) {
      return Scaffold(
        backgroundColor: context.kynosTheme.background,
        body: Column(
          children: [
            CoachChatAppBar(onClear: _confirmClearConversation),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(Spacing.xl),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Could not load conversation',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const Gap(Spacing.sm),
                      Text(
                        'Your chat history could not be restored.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const Gap(Spacing.lg),
                      FilledButton(
                        onPressed: () => ref.invalidate(coachChatProvider),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final messages = chatState.value ?? const [];
    final isStreaming = ref.watch(
      coachChatProvider.select((s) => s.value?.any((m) => m.isStreaming) ?? false),
    );

    return Scaffold(
      backgroundColor: context.kynosTheme.background,
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          CoachChatAppBar(onClear: _confirmClearConversation),
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
            onCancel: isStreaming
                ? () => ref.read(coachChatProvider.notifier).cancelGeneration()
                : null,
          ),
        ],
      ),
    );
  }
}
