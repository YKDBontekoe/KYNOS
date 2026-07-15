import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

    return DecoratedBox(
      decoration: BoxDecoration(
        color: kynos.background,
        boxShadow: kynos.cardShadow,
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Spacing.xs,
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
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(Icons.history_rounded),
                      color: kynos.secondaryLabel,
                      onPressed: () => showConversationListSheet(context),
                      tooltip: 'Conversations',
                    ),
                  ),
                  Container(
                    width: 28,
                    height: 28,
                    alignment: Alignment.center,
                    margin: const EdgeInsets.only(right: Spacing.sm),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [kynos.purple, kynos.stand],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      size: 14,
                      color: KynosColors.onAccent,
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
                        Row(
                          children: [
                            Icon(
                              Icons.lock_outline_rounded,
                              size: 10,
                              color: kynos.exercise,
                            ),
                            const SizedBox(width: 3),
                            Expanded(
                              child: Text(
                                'Private coaching, on your terms',
                                style: Theme.of(context).textTheme.labelSmall,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
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
                    tooltip: 'More',
                    onSelected: (value) {
                      switch (value) {
                        case 'context':
                          showContextInspectorSheet(context);
                        case 'focus_run':
                          showFocusRunPickerSheet(context, ref);
                        case 'coach_settings':
                          showInferenceSettingsSheet(context);
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
                        value: 'export',
                        child: Text('Export chat'),
                      ),
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
      ),
    );
  }
}
