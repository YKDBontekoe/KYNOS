import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kynos/app/router.dart';
import 'package:kynos/core/theme/theme.dart';
import 'package:kynos/features/coach_chat/presentation/widgets/context_inspector_sheet.dart';
import 'package:kynos/features/coach_chat/presentation/widgets/conversation_list_sheet.dart';
import 'package:kynos/features/coach_chat/presentation/widgets/focus_run_picker_sheet.dart';
import 'package:kynos/features/coach_chat/presentation/widgets/inference_settings_sheet.dart';
import 'package:kynos/features/coach_chat/providers/active_coach_conversation_provider.dart';

class CoachChatAppBar extends ConsumerWidget {
  const CoachChatAppBar({
    super.key,
    required this.onDeleteThread,
    required this.onExport,
    required this.onNewChat,
  });

  final VoidCallback onDeleteThread;
  final VoidCallback onExport;
  final VoidCallback onNewChat;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversation = ref.watch(activeCoachConversationProvider).value;
    final kynos = context.kynosTheme;
    final title = conversation?.title ?? 'KYNOS Coach';

    return SafeArea(
      bottom: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Spacing.sm,
              Spacing.xs,
              Spacing.sm,
              Spacing.sm,
            ),
            child: Row(
              children: [
                Semantics(
                  label: 'Conversation history',
                  button: true,
                  child: IconButton(
                    icon: const Icon(Icons.history_rounded),
                    color: kynos.secondaryLabel,
                    onPressed: () => showConversationListSheet(context),
                    tooltip: 'Conversations',
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Private coaching, on your terms',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onNewChat,
                  icon: const Icon(Icons.add_comment_outlined),
                  color: kynos.secondaryLabel,
                  tooltip: 'New conversation',
                ),
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert_rounded,
                    color: kynos.secondaryLabel,
                  ),
                  onSelected: (value) {
                    switch (value) {
                      case 'context':
                        showContextInspectorSheet(context);
                      case 'focus_run':
                        showFocusRunPickerSheet(context, ref);
                      case 'coach_settings':
                        showInferenceSettingsSheet(context);
                      case 'settings':
                        context.push(Routes.settings);
                      case 'export':
                        onExport();
                      case 'delete':
                        onDeleteThread();
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: 'context',
                      child: Text('Context sources'),
                    ),
                    PopupMenuItem(
                      value: 'focus_run',
                      child: Text('Attach focus run'),
                    ),
                    PopupMenuItem(
                      value: 'coach_settings',
                      child: Text('Coach settings'),
                    ),
                    PopupMenuItem(
                      value: 'settings',
                      child: Text('App settings'),
                    ),
                    PopupMenuItem(value: 'export', child: Text('Export chat')),
                    PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete thread'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
