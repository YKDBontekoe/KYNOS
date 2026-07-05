import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:kynos/core/theme/kynos_theme_extension.dart';
import 'package:kynos/core/theme/layout.dart';
import 'package:kynos/core/theme/spacing.dart' as tokens;
import 'package:kynos/core/theme/typography.dart';
import 'package:kynos/shared/widgets/glass_card.dart';
import 'package:kynos/shared/widgets/nav_icon.dart';

/// Configuration for a single tab in [KynosBottomNav].
@immutable
class KynosBottomNavItem {
  const KynosBottomNavItem({
    required this.label,
    required this.iconPath,
  });

  final String label;
  final String iconPath;
}

/// Floating glass bottom navigation bar with a sliding selection indicator.
class KynosBottomNav extends StatelessWidget {
  const KynosBottomNav({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<KynosBottomNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  static const _indicatorDuration = Duration(milliseconds: 250);
  static const _itemAnimDuration = Duration(milliseconds: 200);

  void _handleTap(int index) {
    if (index == selectedIndex) return;
    HapticFeedback.selectionClick();
    onSelected(index);
  }

  Alignment _alignmentFor(int index, int count) {
    if (count <= 1) return Alignment.center;
    final step = 2.0 / (count - 1);
    return Alignment(-1 + step * index, 0);
  }

  @override
  Widget build(BuildContext context) {
    final kynos = context.kynosTheme;

    return RepaintBoundary(
      child: ColoredBox(
        color: Colors.transparent,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: LayoutTokens.shellNavPadding,
            child: DecoratedBox(
              decoration: BoxDecoration(
                boxShadow: kynos.navBarShadow,
                borderRadius: BorderRadius.circular(tokens.Radius.full),
              ),
              child: GlassCard(
                borderRadius: tokens.Radius.full,
                blurSigma: 40,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                tintColor: kynos.glassFill.withValues(alpha: 0.93),
                border: Border.all(
                  color: kynos.glassBorder,
                  width: 0.5,
                ),
                child: SizedBox(
                  height: 64,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      AnimatedAlign(
                        duration: _indicatorDuration,
                        curve: Curves.easeOutCubic,
                        alignment: _alignmentFor(selectedIndex, items.length),
                        child: FractionallySizedBox(
                          widthFactor: 1 / items.length,
                          child: Align(
                            child: Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: kynos.stand.withValues(alpha: 0.10),
                                borderRadius:
                                    BorderRadius.circular(tokens.Radius.sm + 2),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          for (var i = 0; i < items.length; i++)
                            Expanded(
                              child: _NavBarItem(
                                svgPath: items[i].iconPath,
                                label: items[i].label,
                                selected: selectedIndex == i,
                                onTap: () => _handleTap(i),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  const _NavBarItem({
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

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 34,
              height: 34,
              child: Center(
                child: AnimatedSwitcher(
                  duration: KynosBottomNav._itemAnimDuration,
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
              duration: KynosBottomNav._itemAnimDuration,
              style: KynosTypography.navLabel(
                selected: selected,
                color: color,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
