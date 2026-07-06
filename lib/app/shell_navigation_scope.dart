import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kynos/app/router.dart';
import 'package:kynos/features/dashboard/presentation/pages/dashboard_page.dart';

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

/// Today tab — uses shell branch navigation to preserve nested stacks.
class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    final shell = ShellNavigationScope.maybeOf(context);
    return DashboardPage(
      onViewTraining: shell != null
          ? () => shell.goToBranch(1)
          : () => context.go(Routes.training),
      onViewCharacter: shell != null
          ? () => shell.goToBranch(2)
          : () => context.go(Routes.character),
    );
  }
}
