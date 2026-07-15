import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kynos/core/theme/theme.dart';
import 'package:kynos/shared/widgets/nav_icon.dart';

/// iOS-style bottom tab bar for shell destinations.
class KynosTabBar extends StatelessWidget {
  const KynosTabBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
    this.onSettings,
  });

  final List<KynosTabItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final VoidCallback? onSettings;

  @override
  Widget build(BuildContext context) {
    final kynos = context.kynosTheme;
    final bottom = MediaQuery.viewPaddingOf(context).bottom;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: kynos.card.withValues(alpha: 0.94),
        border: Border(
          top: BorderSide(
            color: kynos.separator.withValues(alpha: 0.7),
          ),
        ),
      ),
      child: SizedBox(
        height: LayoutTokens.shellTabBarHeight + bottom,
        child: Padding(
          padding: EdgeInsets.only(bottom: bottom),
          child: Row(
            children: [
              for (var i = 0; i < items.length; i++)
                Expanded(
                  child: _TabButton(
                    item: items[i],
                    selected: selectedIndex == i,
                    onTap: () {
                      if (selectedIndex == i) return;
                      HapticFeedback.selectionClick();
                      onSelected(i);
                    },
                  ),
                ),
              if (onSettings != null)
                SizedBox(
                  width: 56,
                  child: _SettingsButton(onTap: onSettings!),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

@immutable
class KynosTabItem {
  const KynosTabItem({required this.label, required this.icon});

  final String label;
  final NavIconDefinition icon;
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final KynosTabItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final kynos = context.kynosTheme;
    final color = selected ? kynos.purple : kynos.secondaryLabel;

    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomPaint(
              size: const Size(24, 24),
              painter: NavIconPainter(
                pathData: selected ? item.icon.filled : item.icon.outline,
                color: color,
                strokeWidth: selected ? 2.1 : 1.8,
                filled: selected,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: color,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    letterSpacing: -0.1,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsButton extends StatelessWidget {
  const _SettingsButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final kynos = context.kynosTheme;

    return Semantics(
      button: true,
      label: 'Settings',
      child: Tooltip(
        message: 'Settings',
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            onTap();
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.settings_outlined,
                size: 22,
                color: kynos.secondaryLabel,
              ),
              const SizedBox(height: 4),
              Text(
                'Settings',
                maxLines: 1,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: kynos.secondaryLabel,
                      fontWeight: FontWeight.w500,
                      letterSpacing: -0.1,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
