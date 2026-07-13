import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kynos/app/shell_navigation_scope.dart';
import 'package:kynos/core/theme/theme.dart';
import 'package:kynos/features/character/presentation/pages/character_page.dart';
import 'package:kynos/features/training/presentation/pages/training_page.dart';
import 'package:kynos/shared/widgets/kynos_bottom_nav.dart';
import 'package:kynos/shared/widgets/nav_icon.dart';
import 'package:kynos/shared/widgets/responsive_center.dart';

/// Root app shell — floating bottom nav with three focused tabs.
class ShellPage extends ConsumerWidget {
  const ShellPage({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const _navItems = [
    KynosBottomNavItem(label: 'Coach', icon: NavIconPaths.coach),
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
  Widget build(BuildContext context, WidgetRef ref) {
    final kynos = context.kynosTheme;

    return ShellNavigationScope(
      goToBranch: _onTabSelected,
      child: Scaffold(
        backgroundColor: kynos.background,
        extendBody: true,
        body: ResponsiveCenter(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: LayoutTokens.shellNavExtent(context),
            ),
            child: _AnimatedShellBody(
              tabIndex: navigationShell.currentIndex,
              child: navigationShell,
            ),
          ),
        ),
        bottomNavigationBar: Align(
          alignment: Alignment.bottomCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: LayoutTokens.maxContentWidth,
            ),
            child: AnimatedSlide(
              duration: Motion.fast,
              curve: Motion.curve,
              offset: MediaQuery.viewInsetsOf(context).bottom > 0
                  ? const Offset(0, 1.4)
                  : Offset.zero,
              child: AnimatedOpacity(
                duration: Motion.fast,
                opacity: MediaQuery.viewInsetsOf(context).bottom > 0 ? 0 : 1,
                child: KynosBottomNav(
                  items: _navItems,
                  selectedIndex: navigationShell.currentIndex,
                  onSelected: _onTabSelected,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Directional fade/slide on tab index change while preserving [IndexedStack] state.
class _AnimatedShellBody extends StatefulWidget {
  const _AnimatedShellBody({required this.tabIndex, required this.child});

  final int tabIndex;
  final Widget child;

  @override
  State<_AnimatedShellBody> createState() => _AnimatedShellBodyState();
}

class _AnimatedShellBodyState extends State<_AnimatedShellBody>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<Offset> _slide;
  late Animation<double> _fade;
  int _previousIndex = 0;
  int _direction = 1;

  @override
  void initState() {
    super.initState();
    _previousIndex = widget.tabIndex;
    _controller = AnimationController(vsync: this, duration: Motion.medium)
      ..value = 1;
    _buildAnimations();
  }

  void _buildAnimations() {
    final slideOffset = 0.15 * _direction;
    final curved = CurvedAnimation(parent: _controller, curve: Motion.curve);
    _slide = Tween<Offset>(
      begin: Offset(slideOffset, 0),
      end: Offset.zero,
    ).animate(curved);
    _fade = curved;
  }

  @override
  void didUpdateWidget(_AnimatedShellBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.tabIndex != oldWidget.tabIndex) {
      _direction = widget.tabIndex > _previousIndex ? 1 : -1;
      _previousIndex = widget.tabIndex;
      _buildAnimations();
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
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
