import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kynos/app/router.dart';
import 'package:kynos/core/theme/layout.dart';
import 'package:kynos/core/theme/theme.dart';
import 'package:kynos/features/character/presentation/pages/character_page.dart';
import 'package:kynos/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:kynos/features/training/presentation/pages/training_page.dart';
import 'package:kynos/shared/widgets/kynos_bottom_nav.dart';
import 'package:kynos/shared/widgets/nav_icon.dart';
import 'package:kynos/shared/widgets/responsive_center.dart';

/// Root app shell — floating bottom nav with three focused tabs.
class ShellPage extends StatelessWidget {
  const ShellPage({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const _navItems = [
    KynosBottomNavItem(label: 'Today', icon: NavIconPaths.today),
    KynosBottomNavItem(label: 'Training', icon: NavIconPaths.training),
    KynosBottomNavItem(label: 'Character', icon: NavIconPaths.character),
  ];

  void _onTabSelected(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final kynos = context.kynosTheme;
    return Scaffold(
      backgroundColor: kynos.background,
      extendBody: true,
      body: ResponsiveCenter(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: LayoutTokens.shellNavExtent(context),
          ),
          child: navigationShell,
        ),
      ),
      bottomNavigationBar: ResponsiveCenter(
        child: KynosBottomNav(
          items: _navItems,
          selectedIndex: navigationShell.currentIndex,
          onSelected: _onTabSelected,
        ),
      ),
    );
  }
}

/// Today tab — extracted for [StatefulShellRoute].
class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardPage(
      onViewTraining: () => context.go(Routes.training),
      onViewCharacter: () => context.go(Routes.character),
    );
  }
}

/// Training tab — extracted for [StatefulShellRoute].
class TrainingTab extends StatelessWidget {
  const TrainingTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const TrainingPage();
  }
}

/// Character tab — extracted for [StatefulShellRoute].
class CharacterTab extends StatelessWidget {
  const CharacterTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const CharacterPage();
  }
}
