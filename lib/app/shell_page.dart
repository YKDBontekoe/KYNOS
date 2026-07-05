import 'package:flutter/material.dart';
import 'package:kynos/core/theme/app_theme.dart';
import 'package:kynos/features/character/presentation/pages/character_page.dart';
import 'package:kynos/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:kynos/features/training/presentation/pages/training_page.dart';
import 'package:kynos/shared/widgets/kynos_bottom_nav.dart';
import 'package:kynos/shared/widgets/nav_icon.dart';

/// Root app shell — floating bottom nav with three focused tabs.
class ShellPage extends StatefulWidget {
  const ShellPage({super.key});

  @override
  State<ShellPage> createState() => _ShellState();
}

class _ShellState extends State<ShellPage> {
  int _index = 0;

  static const _navItems = [
    KynosBottomNavItem(label: 'Today', iconPath: NavIconPaths.home),
    KynosBottomNavItem(label: 'Training', iconPath: NavIconPaths.activity),
    KynosBottomNavItem(label: 'Character', iconPath: NavIconPaths.character),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      extendBody: true,
      body: IndexedStack(
        index: _index,
        children: [
          DashboardPage(
            onViewTraining: () => setState(() => _index = 1),
            onViewCharacter: () => setState(() => _index = 2),
          ),
          const TrainingPage(),
          const CharacterPage(),
        ],
      ),
      bottomNavigationBar: KynosBottomNav(
        items: _navItems,
        selectedIndex: _index,
        onSelected: (i) => setState(() => _index = i),
      ),
    );
  }
}
