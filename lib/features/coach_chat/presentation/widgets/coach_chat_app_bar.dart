import 'package:flutter/material.dart';
import 'package:kynos/core/theme/theme.dart';
import 'package:kynos/features/coach_chat/presentation/widgets/conversation_list_sheet.dart';
import 'package:kynos/features/coach_chat/presentation/widgets/inference_settings_sheet.dart';

/// Minimal coach actions — page identity lives in the shared bottom tabs.
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

  @override
  Widget build(BuildContext context) {
    final kynos = context.kynosTheme;

    return ColoredBox(
      color: kynos.background,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 44,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.xs),
            child: Row(
              children: [
                IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Conversations',
                  onPressed: () => showConversationListSheet(context),
                  icon: Icon(
                    Icons.chat_bubble_outline_rounded,
                    color: kynos.label,
                    size: 22,
                  ),
                ),
                const Spacer(),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Model & mode',
                  onPressed: () => showInferenceSettingsSheet(
                    context,
                    onExport: onExport,
                    onDeleteThread: onDeleteThread,
                  ),
                  icon: Icon(
                    Icons.auto_awesome_rounded,
                    color: kynos.secondaryLabel,
                    size: 20,
                  ),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: 'New conversation',
                  onPressed: onNewChat,
                  icon: Icon(
                    Icons.edit_outlined,
                    color: kynos.label,
                    size: 22,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
