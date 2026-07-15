import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kynos/app/router.dart';
import 'package:kynos/app/shell_navigation_scope.dart';
import 'package:kynos/core/theme/theme.dart';
import 'package:kynos/features/coach_chat/presentation/widgets/conversation_list_sheet.dart';
import 'package:kynos/features/coach_chat/presentation/widgets/inference_settings_sheet.dart';

/// Quiet, one-line coach chrome.
class CoachChatAppBar extends StatelessWidget {
  const CoachChatAppBar({
    super.key,
    required this.onDeleteThread,
    required this.onExport,
    required this.onNewChat,
  });

  final VoidCallback onDeleteThread;
  final VoidCallback onExport;
  final VoidCallback onNewChat;

  void _openMenu(BuildContext context) {
    final shell = ShellNavigationScope.maybeOf(context);
    final kynos = context.kynosTheme;

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: kynos.background,
      builder: (sheetContext) => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            Spacing.sm,
            0,
            Spacing.sm,
            Spacing.md,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.chat_bubble_outline_rounded),
                title: const Text('Conversations'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  showConversationListSheet(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.tune_rounded),
                title: const Text('Model & mode'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  showInferenceSettingsSheet(
                    context,
                    onExport: onExport,
                    onDeleteThread: onDeleteThread,
                  );
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.monitor_heart_outlined),
                title: const Text('Health'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  shell?.goToBranch(1);
                },
              ),
              ListTile(
                leading: const Icon(Icons.landscape_outlined),
                title: const Text('Journey'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  shell?.goToBranch(2);
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings_outlined),
                title: const Text('Settings'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  context.push(Routes.settings);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final kynos = context.kynosTheme;

    return ColoredBox(
      color: kynos.background,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 48,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.xs),
            child: Row(
              children: [
                IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Menu',
                  onPressed: () => _openMenu(context),
                  icon: Icon(Icons.menu_rounded, color: kynos.label),
                ),
                Expanded(
                  child: Text(
                    'Coach',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.2,
                        ),
                  ),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: 'New conversation',
                  onPressed: onNewChat,
                  icon: Icon(Icons.edit_square, color: kynos.label),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
