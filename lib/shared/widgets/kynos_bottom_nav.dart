import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:kynos/core/theme/kynos_theme_extension.dart';
import 'package:kynos/core/theme/layout.dart';
import 'package:kynos/core/theme/motion.dart';
import 'package:kynos/core/theme/liquid_glass_tokens.dart';
import 'package:kynos/core/theme/spacing.dart' as tokens;
import 'package:kynos/core/theme/typography.dart';
import 'package:kynos/shared/widgets/liquid_glass_surface.dart';
import 'package:kynos/shared/widgets/nav_icon.dart';

/// Configuration for a single tab in [KynosBottomNav].
@immutable
class KynosBottomNavItem {
  const KynosBottomNavItem({
    required this.label,
    required this.icon,
  });

  final String label;
  final NavIconDefinition icon;
}

/// Floating Liquid Glass bottom navigation bar with a sliding glass pill indicator.
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
              child: LiquidGlassSurface(
                borderRadius: tokens.Radius.full,
                blurSigma: LiquidGlassTokens.navBlurSigma,
                padding: const EdgeInsets.symmetric(
                  horizontal: tokens.Spacing.xs,
                  vertical: tokens.Spacing.xs,
                ),
                child: SizedBox(
                  height: 60,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      AnimatedAlign(
                        duration: Motion.navIndicator,
                        curve: Motion.curve,
                        alignment:
                            _alignmentFor(selectedIndex, items.length),
                        child: FractionallySizedBox(
                          widthFactor: 1 / items.length,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: tokens.Spacing.xs,
                            ),
                            child: LiquidGlassSurface(
                              borderRadius: tokens.Radius.full,
                              blurSigma: LiquidGlassTokens.indicatorBlurSigma,
                              padding: EdgeInsets.zero,
                              applyVibrancy: false,
                              tintColor: kynos.stand.withValues(alpha: 0.14),
                              child: const SizedBox(height: 44),
                            ),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          for (var i = 0; i < items.length; i++)
                            Expanded(
                              child: _NavBarItem(
                                icon: items[i].icon,
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
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final NavIconDefinition icon;
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
            AnimatedScale(
              scale: selected ? 1.05 : 1.0,
              duration: Motion.navItem,
              curve: Motion.curve,
              child: SizedBox(
                width: 28,
                height: 28,
                child: AnimatedSwitcher(
                  duration: Motion.navItem,
                  switchInCurve: Motion.curve,
                  switchOutCurve: Motion.curveIn,
                  child: CustomPaint(
                    key: ValueKey('$label-$selected'),
                    size: const Size(24, 24),
                    painter: NavIconPainter(
                      pathData: selected ? icon.filled : icon.outline,
                      color: color,
                      strokeWidth: 2.0,
                      filled: selected,
                    ),
                  ),
                ),
              ),
            ),
            const Gap(tokens.Spacing.xs),
            AnimatedDefaultTextStyle(
              duration: Motion.navItem,
              curve: Motion.curve,
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
