import 'package:flutter/material.dart';
import 'package:kynos/core/theme/theme.dart';
import 'package:kynos/features/coach_chat/presentation/widgets/coach_navigation_sheet.dart';

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
                  onPressed: () => showCoachNavigationSheet(
                    context,
                    onExport: onExport,
                    onDeleteThread: onDeleteThread,
                  ),
                  icon: Icon(
                    Icons.menu_rounded,
                    color: kynos.label,
                    size: 22,
                  ),
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
