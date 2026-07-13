import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:kynos/core/theme/kynos_theme_extension.dart';
import 'package:kynos/core/theme/liquid_glass_tokens.dart';
import 'package:kynos/core/theme/motion.dart';
import 'package:kynos/core/theme/spacing.dart' as tokens;
import 'package:kynos/shared/widgets/liquid_glass_surface.dart';
import 'package:kynos/shared/widgets/nav_icon.dart';

/// Configuration for a single tab destination in [KynosFloatingNav].
@immutable
class KynosFloatingNavItem {
  const KynosFloatingNavItem({required this.label, required this.icon});

  final String label;
  final NavIconDefinition icon;
}

/// Secondary action shown below tab destinations when the nav menu expands.
@immutable
class KynosFloatingNavAction {
  const KynosFloatingNavAction({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
}

/// Draggable bottom-left floating navigation button that expands into tab options.
class KynosFloatingNav extends StatefulWidget {
  const KynosFloatingNav({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
    this.actions = const [],
  });

  final List<KynosFloatingNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final List<KynosFloatingNavAction> actions;

  static const double _fabSize = 52;
  static const double _itemSize = 44;
  static const double _dragThreshold = 8;

  @override
  State<KynosFloatingNav> createState() => _KynosFloatingNavState();
}

class _KynosFloatingNavState extends State<KynosFloatingNav>
    with SingleTickerProviderStateMixin {
  static const double _fabSize = KynosFloatingNav._fabSize;
  static const double _itemSize = KynosFloatingNav._itemSize;

  late final AnimationController _expandController;
  late final Animation<double> _expandAnimation;

  bool _expanded = false;
  Offset? _position;
  double _dragDistance = 0;

  @override
  void initState() {
    super.initState();
    _expandController = AnimationController(vsync: this, duration: Motion.medium);
    _expandAnimation = CurvedAnimation(
      parent: _expandController,
      curve: Motion.curve,
      reverseCurve: Motion.curveIn,
    );
  }

  @override
  void dispose() {
    _expandController.dispose();
    super.dispose();
  }

  void _setExpanded(bool value) {
    if (_expanded == value) return;
    setState(() => _expanded = value);
    if (value) {
      _expandController.forward();
    } else {
      _expandController.reverse();
    }
  }

  void _toggleExpanded() => _setExpanded(!_expanded);

  void _handleActionTap(KynosFloatingNavAction action) {
    HapticFeedback.selectionClick();
    action.onTap();
    _setExpanded(false);
  }

  void _handleItemTap(int index) {
    if (index == widget.selectedIndex) {
      _setExpanded(false);
      return;
    }
    HapticFeedback.selectionClick();
    widget.onSelected(index);
    _setExpanded(false);
  }

  void _onPanStart(DragStartDetails details) {
    _dragDistance = 0;
  }

  void _onPanUpdate(DragUpdateDetails details, Size parentSize) {
    _dragDistance += details.delta.distance;
    if (_dragDistance > KynosFloatingNav._dragThreshold && _expanded) {
      _setExpanded(false);
    }

    final current = _position ?? _defaultPosition(parentSize);
    setState(() {
      _position = _clampPosition(
        current + details.delta,
        parentSize,
        expanded: _expanded,
      );
    });
  }

  void _onPanEnd(DragEndDetails details) {
    _dragDistance = 0;
  }

  Offset _defaultPosition(Size parentSize) {
    final viewPadding = MediaQuery.viewPaddingOf(context);
    return Offset(
      tokens.Spacing.md + viewPadding.left,
      tokens.Spacing.md + viewPadding.bottom,
    );
  }

  double _stackHeight({required bool expanded}) {
    if (!expanded) return _fabSize;
    final menuItemCount = widget.items.length + widget.actions.length;
    if (menuItemCount == 0) return _fabSize;
    return _fabSize +
        tokens.Spacing.xs +
        (menuItemCount * _itemSize) +
        ((menuItemCount - 1) * tokens.Spacing.xs);
  }

  Offset _clampPosition(
    Offset position,
    Size parentSize, {
    required bool expanded,
  }) {
    final viewPadding = MediaQuery.viewPaddingOf(context);
    final stackHeight = _stackHeight(expanded: expanded);
    final minLeft = viewPadding.left + tokens.Spacing.xs;
    final minBottom = viewPadding.bottom + tokens.Spacing.xs;
    final maxLeft = math.max(
      minLeft,
      parentSize.width - _fabSize - viewPadding.right - tokens.Spacing.xs,
    );
    final maxBottom = math.max(
      minBottom,
      parentSize.height - stackHeight - viewPadding.top - tokens.Spacing.xs,
    );

    return Offset(
      position.dx.clamp(minLeft, maxLeft),
      position.dy.clamp(minBottom, maxBottom),
    );
  }

  @override
  Widget build(BuildContext context) {
    final kynos = context.kynosTheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final parentSize = Size(constraints.maxWidth, constraints.maxHeight);
        final position = _position ?? _defaultPosition(parentSize);
        final clamped = _clampPosition(
          position,
          parentSize,
          expanded: _expanded,
        );
        if (_position != clamped) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            setState(() => _position = clamped);
          });
        }

        return Stack(
          fit: StackFit.expand,
          clipBehavior: Clip.none,
          children: [
            if (_expanded)
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _setExpanded(false),
                  child: const ColoredBox(color: Colors.transparent),
                ),
              ),
            Positioned(
              left: clamped.dx,
              bottom: clamped.dy,
              child: _FloatingNavControl(
                items: widget.items,
                actions: widget.actions,
                selectedIndex: widget.selectedIndex,
                expanded: _expanded,
                expandAnimation: _expandAnimation,
                accent: kynos.purple,
                unselected: kynos.navUnselected,
                shadow: kynos.navBarShadow,
                onItemTap: _handleItemTap,
                onActionTap: _handleActionTap,
                onFabTap: _toggleExpanded,
                onPanStart: _onPanStart,
                onPanUpdate: (details) => _onPanUpdate(details, parentSize),
                onPanEnd: _onPanEnd,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _FloatingNavControl extends StatelessWidget {
  const _FloatingNavControl({
    required this.items,
    required this.actions,
    required this.selectedIndex,
    required this.expanded,
    required this.expandAnimation,
    required this.accent,
    required this.unselected,
    required this.shadow,
    required this.onItemTap,
    required this.onActionTap,
    required this.onFabTap,
    required this.onPanStart,
    required this.onPanUpdate,
    required this.onPanEnd,
  });

  final List<KynosFloatingNavItem> items;
  final List<KynosFloatingNavAction> actions;
  final int selectedIndex;
  final bool expanded;
  final Animation<double> expandAnimation;
  final Color accent;
  final Color unselected;
  final List<BoxShadow> shadow;
  final ValueChanged<int> onItemTap;
  final ValueChanged<KynosFloatingNavAction> onActionTap;
  final VoidCallback onFabTap;
  final GestureDragStartCallback onPanStart;
  final GestureDragUpdateCallback onPanUpdate;
  final GestureDragEndCallback onPanEnd;

  static const double _fabSize = KynosFloatingNav._fabSize;

  @override
  Widget build(BuildContext context) {
    final hasItems = items.isNotEmpty;
    final selectedItem = hasItems
        ? items[selectedIndex.clamp(0, items.length - 1)]
        : null;

    return GestureDetector(
      key: const Key('kynos_floating_nav_control'),
      onPanStart: onPanStart,
      onPanUpdate: onPanUpdate,
      onPanEnd: onPanEnd,
      dragStartBehavior: DragStartBehavior.down,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizeTransition(
            sizeFactor: expandAnimation,
            alignment: Alignment.bottomCenter,
            child: FadeTransition(
              opacity: expandAnimation,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < items.length; i++) ...[
                    if (i > 0) const Gap(tokens.Spacing.xs),
                    _NavOption(
                      icon: items[i].icon,
                      label: items[i].label,
                      selected: selectedIndex == i,
                      accent: accent,
                      unselected: unselected,
                      onTap: () => onItemTap(i),
                    ),
                  ],
                  for (var i = 0; i < actions.length; i++) ...[
                    if (hasItems || i > 0) const Gap(tokens.Spacing.xs),
                    _NavActionOption(
                      label: actions[i].label,
                      icon: actions[i].icon,
                      unselected: unselected,
                      onTap: () => onActionTap(actions[i]),
                    ),
                  ],
                  const Gap(tokens.Spacing.xs),
                ],
              ),
            ),
          ),
          Semantics(
            button: true,
            label: expanded
                ? 'Collapse navigation menu'
                : 'Open navigation menu',
            child: GestureDetector(
              onTap: onFabTap,
              behavior: HitTestBehavior.opaque,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  boxShadow: shadow,
                  borderRadius: BorderRadius.circular(tokens.Radius.full),
                ),
                child: LiquidGlassSurface(
                  borderRadius: tokens.Radius.full,
                  blurSigma: LiquidGlassTokens.navBlurSigma,
                  padding: EdgeInsets.zero,
                  child: SizedBox(
                    width: _fabSize,
                    height: _fabSize,
                    child: Center(
                      child: AnimatedRotation(
                        turns: expanded ? 0.125 : 0,
                        duration: Motion.navItem,
                        curve: Motion.curve,
                        child: selectedItem != null
                            ? CustomPaint(
                                size: const Size(24, 24),
                                painter: NavIconPainter(
                                  pathData: selectedItem.icon.filled,
                                  color: accent,
                                  strokeWidth: 2,
                                  filled: true,
                                ),
                              )
                            : Icon(
                                actions.isNotEmpty
                                    ? actions.first.icon
                                    : Icons.menu_rounded,
                                size: 24,
                                color: accent,
                              ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavActionOption extends StatelessWidget {
  const _NavActionOption({
    required this.label,
    required this.icon,
    required this.unselected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color unselected;
  final VoidCallback onTap;

  static const double _itemSize = KynosFloatingNav._itemSize;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: Tooltip(
        message: label,
        waitDuration: const Duration(milliseconds: 400),
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: LiquidGlassSurface(
            borderRadius: tokens.Radius.lg,
            blurSigma: LiquidGlassTokens.navBlurSigma,
            padding: EdgeInsets.zero,
            child: SizedBox(
              width: _itemSize,
              height: _itemSize,
              child: Center(
                child: Icon(icon, size: 22, color: unselected),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavOption extends StatelessWidget {
  const _NavOption({
    required this.icon,
    required this.label,
    required this.selected,
    required this.accent,
    required this.unselected,
    required this.onTap,
  });

  final NavIconDefinition icon;
  final String label;
  final bool selected;
  final Color accent;
  final Color unselected;
  final VoidCallback onTap;

  static const double _itemSize = KynosFloatingNav._itemSize;

  @override
  Widget build(BuildContext context) {
    final color = selected ? accent : unselected;

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: Tooltip(
        message: label,
        waitDuration: const Duration(milliseconds: 400),
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: LiquidGlassSurface(
            borderRadius: tokens.Radius.lg,
            blurSigma: LiquidGlassTokens.navBlurSigma,
            padding: EdgeInsets.zero,
            child: AnimatedContainer(
              duration: Motion.navItem,
              curve: Motion.curve,
              width: _itemSize,
              height: _itemSize,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(tokens.Radius.lg),
                color: selected ? accent.withValues(alpha: 0.14) : Colors.transparent,
              ),
              child: Center(
                child: AnimatedScale(
                  scale: selected ? 1.06 : 1,
                  duration: Motion.navItem,
                  curve: Motion.curve,
                  child: CustomPaint(
                    size: const Size(24, 24),
                    painter: NavIconPainter(
                      pathData: selected ? icon.filled : icon.outline,
                      color: color,
                      strokeWidth: 2,
                      filled: selected,
                    ),
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
