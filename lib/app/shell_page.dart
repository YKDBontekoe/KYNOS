import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kynos/app/router.dart';
import 'package:kynos/app/shell_navigation_scope.dart';
import 'package:kynos/core/theme/theme.dart';
import 'package:kynos/shared/providers/shell_chrome_provider.dart';
import 'package:kynos/shared/widgets/kynos_tab_bar.dart';
import 'package:kynos/shared/widgets/nav_icon.dart';
import 'package:kynos/shared/widgets/responsive_center.dart';

/// Root app shell — coach-only home with a settings affordance in the dock.
class ShellPage extends ConsumerWidget {
  const ShellPage({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const _tabItems = [
    KynosTabItem(label: 'Coach', icon: NavIconPaths.coach),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kynos = context.kynosTheme;
    final chromeVisible = ref.watch(shellChromeProvider);

    return ShellNavigationScope(
      goToBranch: (_) {},
      child: Scaffold(
        backgroundColor: kynos.background,
        body: Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
              top: -120,
              right: -80,
              child: IgnorePointer(
                child: Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        kynos.purple.withValues(alpha: 0.08),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            ResponsiveCenter(
              child: navigationShell,
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: AnimatedSwitcher(
                duration: Motion.medium,
                switchInCurve: Motion.curve,
                switchOutCurve: Motion.curve,
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.35),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: chromeVisible
                    ? KynosTabBar(
                        key: const ValueKey('shell-tab-bar'),
                        items: _tabItems,
                        selectedIndex: 0,
                        onSelected: (_) {},
                        onSettings: () => context.push(Routes.settings),
                      )
                    : const SizedBox.shrink(key: ValueKey('shell-tab-bar-hidden')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
