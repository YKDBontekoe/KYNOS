import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:kynos/core/theme/app_theme.dart';
import 'package:kynos/core/theme/kynos_theme_extension.dart';
import 'package:kynos/core/theme/layout.dart';
import 'package:kynos/core/theme/spacing.dart' as tokens;
import 'package:kynos/core/theme/typography.dart';
import 'package:kynos/features/character/presentation/pages/character_page.dart';
import 'package:kynos/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:kynos/features/training/presentation/pages/training_page.dart';
import 'package:kynos/shared/widgets/glass_card.dart';
import 'package:kynos/shared/widgets/nav_icon.dart';

/// Root app shell — floating bottom nav with three focused tabs.
class ShellPage extends StatefulWidget {
  const ShellPage({super.key});

  @override
  State<ShellPage> createState() => _ShellState();
}

class _ShellState extends State<ShellPage> {
  int _index = 0;

  static const _labels = ['Today', 'Training', 'Character'];

  static const _navPaths = [
    NavIconPaths.home,
    NavIconPaths.activity,
    NavIconPaths.character,
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
      bottomNavigationBar: _BottomBar(
        labels: _labels,
        paths: _navPaths,
        selectedIndex: _index,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.labels,
    required this.paths,
    required this.selectedIndex,
    required this.onTap,
  });

  final List<String> labels;
  final List<String> paths;
  final int selectedIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.transparent,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: LayoutTokens.shellNavPadding,
          child: GlassCard(
            borderRadius: tokens.Radius.full,
            blurSigma: 40,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            tintColor: context.kynosTheme.glassFill.withValues(alpha: 0.93),
            border: Border.all(
              color: Colors.black.withValues(alpha: 0.08),
              width: 0.5,
            ),
            child: SizedBox(
              height: 64,
              child: Row(
                children: [
                  for (var i = 0; i < labels.length; i++)
                    Expanded(
                      child: _BarItem(
                        svgPath: paths[i],
                        label: labels[i],
                        selected: selectedIndex == i,
                        onTap: () => onTap(i),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BarItem extends StatelessWidget {
  const _BarItem({
    required this.svgPath,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String svgPath;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final kynos = context.kynosTheme;
    final color = selected ? kynos.stand : kynos.navUnselected;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: selected
                  ? AppTheme.stand.withValues(alpha: 0.10)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: CustomPaint(
                  key: ValueKey('$svgPath-$selected'),
                  size: const Size(22, 22),
                  painter: NavIconPainter(
                    pathData: svgPath,
                    color: color,
                    strokeWidth: selected ? 2.0 : 1.8,
                  ),
                ),
              ),
            ),
          ),
          const Gap(tokens.Spacing.xs),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: KynosTypography.navLabel(
              selected: selected,
              color: color,
            ),
            child: Text(label),
          ),
        ],
      ),
    );
  }
}
