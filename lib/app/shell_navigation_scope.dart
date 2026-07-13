import 'package:flutter/material.dart';
import 'package:kynos/features/coach_chat/presentation/pages/coach_chat_page.dart';

/// Exposes shell branch switching to descendant tab routes.
class ShellNavigationScope extends InheritedWidget {
  const ShellNavigationScope({
    super.key,
    required this.goToBranch,
    required super.child,
  });

  final ValueChanged<int> goToBranch;

  static ShellNavigationScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ShellNavigationScope>();
  }

  @override
  bool updateShouldNotify(ShellNavigationScope oldWidget) =>
      goToBranch != oldWidget.goToBranch;
}

/// Coach home tab — uses shell navigation to preserve the other tab stacks.
class CoachTab extends StatelessWidget {
  const CoachTab({super.key, this.threadId});

  final String? threadId;

  @override
  Widget build(BuildContext context) {
    return CoachChatPage(threadId: threadId);
  }
}
