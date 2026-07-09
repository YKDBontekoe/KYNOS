import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:kynos/app/router.dart';
import 'package:kynos/core/theme/theme.dart';
import 'package:kynos/domain/entities/coach/coach_backend_mode.dart';
import 'package:kynos/domain/entities/coach/coach_chat_seed.dart';
import 'package:kynos/domain/entities/coach/coach_data_source.dart';
import 'package:kynos/domain/entities/coach/coach_seed_topic.dart';
import 'package:kynos/domain/utils/ai_inference_error_policy.dart';
import 'package:kynos/domain/utils/coach_follow_up_suggestions.dart';
import 'package:kynos/features/coach_chat/presentation/widgets/chat_input_bar.dart';
import 'package:kynos/features/coach_chat/presentation/widgets/cloud_consent_banner.dart';
import 'package:kynos/features/coach_chat/presentation/widgets/coach_chat_app_bar.dart';
import 'package:kynos/features/coach_chat/presentation/widgets/follow_up_chips.dart';
import 'package:kynos/features/coach_chat/presentation/widgets/inference_mode_bar.dart';
import 'package:kynos/features/coach_chat/presentation/widgets/message_list.dart';
import 'package:kynos/features/coach_chat/presentation/widgets/model_setup_screen.dart';
import 'package:kynos/features/coach_chat/providers/active_coach_conversation_provider.dart';
import 'package:kynos/features/coach_chat/providers/coach_chat_provider.dart';
import 'package:kynos/features/coach_chat/providers/coach_conversations_provider.dart';
import 'package:kynos/features/coach_chat/providers/model_setup_provider.dart';
import 'package:kynos/shared/providers/ai_reconnect_provider.dart';
import 'package:kynos/shared/providers/ai_repository_providers.dart';
import 'package:kynos/shared/providers/coach_chat_seed_provider.dart';
import 'package:kynos/shared/providers/coach_conversation_providers.dart';
import 'package:kynos/shared/providers/settings_provider.dart';

class CoachChatPage extends ConsumerStatefulWidget {
  const CoachChatPage({super.key, this.threadId});

  final String? threadId;

  @override
  ConsumerState<CoachChatPage> createState() => _CoachChatPageState();
}

class _CoachChatPageState extends ConsumerState<CoachChatPage> {
  final _scrollController = ScrollController();
  final _textController = TextEditingController();
  final _focusNode = FocusNode();
  bool _seedApplied = false;
  bool _initialized = false;
  String? _pendingMessage;
  bool _showCloudConsent = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(modelSetupProvider.notifier).checkAndInstall();
      _initializeConversation();
    });
  }

  Future<void> _initializeConversation() async {
    if (_initialized) return;
    _initialized = true;

    final notifier = ref.read(coachConversationsProvider.notifier);
    CoachChatSeedData? seed;
    if (widget.threadId != null) {
      await notifier.switchConversation(widget.threadId!);
      ref.invalidate(coachChatProvider);
      return;
    }

    final consumed = ref.read(coachChatSeedProvider.notifier).consumeSeed();
    seed = consumed;

    await notifier.ensureActiveConversation(seed: seed);
    ref.invalidate(coachChatProvider);
    ref.invalidate(activeCoachConversationProvider);
  }

  void _applyCoachSeed() {
    if (!mounted || _seedApplied) return;
    final conversation = ref.read(activeCoachConversationProvider).value;
    final seed = conversation?.seed;
    if (seed == null || seed.isEmpty) return;
    _seedApplied = true;
    _textController.text = seed.message ?? '';
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

  bool _needsCloudConsent() {
    final conversation = ref.read(activeCoachConversationProvider).value;
    if (conversation == null) return false;
    final settings = conversation.settings;
    if (settings.contextPreferences.cloudConsentGiven) return false;
    if (settings.backendMode == CoachBackendMode.cloud) return true;
    if (settings.backendMode == CoachBackendMode.auto) {
      return ref.read(isCloudCoachConfiguredProvider).value ?? false;
    }
    return false;
  }

  void _handleSend([String? override]) {
    final text = (override ?? _textController.text).trim();
    if (text.isEmpty) return;

    if (_needsCloudConsent()) {
      setState(() {
        _pendingMessage = text;
        _showCloudConsent = true;
      });
      return;
    }

    _textController.clear();
    ref.read(coachChatProvider.notifier).sendMessage(text);
  }

  Future<void> _confirmCloudConsent() async {
    final conversation = ref.read(activeCoachConversationProvider).value;
    if (conversation == null) return;
    final next = conversation.settings.copyWith(
      contextPreferences: conversation.settings.contextPreferences.copyWith(
        cloudConsentGiven: true,
      ),
    );
    await ref.read(coachChatProvider.notifier).updateSettings(next);
    setState(() => _showCloudConsent = false);
    final pending = _pendingMessage;
    _pendingMessage = null;
    if (pending != null) {
      _textController.clear();
      await ref.read(coachChatProvider.notifier).sendMessage(pending);
    }
  }

  Future<void> _confirmDeleteThread() async {
    final conversation = ref.read(activeCoachConversationProvider).value;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete conversation?'),
        content: const Text(
          'This permanently deletes this chat thread and its messages.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    if (conversation != null) {
      await ref
          .read(coachConversationsProvider.notifier)
          .deleteConversation(conversation.id);
    }
    await ref.read(coachConversationsProvider.notifier).ensureActiveConversation();
    ref.invalidate(coachChatProvider);
    ref.invalidate(activeCoachConversationProvider);
  }

  Future<void> _exportThread() async {
    final conversation = ref.read(activeCoachConversationProvider).value;
    if (conversation == null) return;
    final text = ref.read(exportCoachConversationUseCaseProvider).call(conversation);
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Conversation copied to clipboard')),
    );
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

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('On-device coach will reconnect on your next message.'),
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
    final conversation = ref.watch(activeCoachConversationProvider).value;
    final globalSettings = ref.watch(settingsProvider);

    ref.listen(
      coachChatProvider.select((s) => s.value?.lastOrNull?.content),
      (prev, next) => _scrollToBottom(),
    );

    if (chatState.hasError && !chatState.isLoading) {
      return Scaffold(
        backgroundColor: context.kynosTheme.background,
        body: Column(
          children: [
            CoachChatAppBar(
              onDeleteThread: _confirmDeleteThread,
              onExport: _exportThread,
            ),
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

    final followUps = !isStreaming && messages.isNotEmpty
        ? CoachFollowUpSuggestions.forContext(
            enabledSources:
                conversation?.settings.contextPreferences.enabledSources ??
                    CoachDataSource.all.toSet(),
            topic: conversation?.seed?.topic ?? CoachSeedTopic.general,
          )
        : const <String>[];

    final enabledLabels = conversation?.settings.contextPreferences.enabledSources
            .map((s) => s.label)
            .toList() ??
        const <String>[];

    return Scaffold(
      backgroundColor: context.kynosTheme.background,
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          CoachChatAppBar(
            onDeleteThread: _confirmDeleteThread,
            onExport: _exportThread,
          ),
          const InferenceModeBar(),
          if (_showCloudConsent)
            CloudConsentBanner(
              enabledSourceLabels: enabledLabels,
              cloudDataLevelLabel: globalSettings.cloudDataLevel.label,
              onConfirm: _confirmCloudConsent,
              onCancel: () => setState(() {
                _showCloudConsent = false;
                _pendingMessage = null;
              }),
            ),
          Expanded(
            child: messages.isEmpty
                ? CoachChatEmptyState(onSuggestionTap: _handleSend)
                : MessageList(
                    messages: messages,
                    scrollController: _scrollController,
                  ),
          ),
          if (followUps.isNotEmpty)
            FollowUpChips(suggestions: followUps, onTap: _handleSend),
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
