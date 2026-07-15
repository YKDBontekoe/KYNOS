import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kynos/app/router.dart';
import 'package:kynos/app/shell_navigation_scope.dart';
import 'package:kynos/core/theme/theme.dart';
import 'package:kynos/features/character/presentation/pages/character_page.dart';
import 'package:kynos/features/training/presentation/pages/training_page.dart';
import 'package:kynos/shared/providers/shell_chrome_provider.dart';
import 'package:kynos/shared/widgets/kynos_tab_bar.dart';
import 'package:kynos/shared/widgets/nav_icon.dart';
import 'package:kynos/shared/widgets/responsive_center.dart';

/// Root app shell — content fills the screen with a floating glass tab dock.
class ShellPage extends ConsumerWidget {
  const ShellPage({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const _tabItems = [
    KynosTabItem(label: 'Coach', icon: NavIconPaths.coach),
    KynosTabItem(label: 'Health', icon: NavIconPaths.health),
    KynosTabItem(label: 'Journey', icon: NavIconPaths.journey),
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
    final chromeVisible = ref.watch(shellChromeProvider);

    return ShellNavigationScope(
      goToBranch: _onTabSelected,
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
              child: _AnimatedShellBody(
                tabIndex: navigationShell.currentIndex,
                child: navigationShell,
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: IgnorePointer(
                ignoring: !chromeVisible,
                child: AnimatedSlide(
                  duration: Motion.medium,
                  curve: Motion.curve,
                  offset: chromeVisible ? Offset.zero : const Offset(0, 1.2),
                  child: AnimatedOpacity(
                    duration: Motion.medium,
                    curve: Motion.curve,
                    opacity: chromeVisible ? 1 : 0,
                    child: KynosTabBar(
                      items: _tabItems,
                      selectedIndex: navigationShell.currentIndex,
                      onSelected: _onTabSelected,
                      onSettings: () => context.push(Routes.settings),
                    ),
                  ),
                ),
              ),
            ),
          ],
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
    final slideOffset = 0.08 * _direction;
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
    return SizedBox.expand(
      child: FadeTransition(
        opacity: _fade,
        child: SlideTransition(position: _slide, child: widget.child),
      ),
    );
  }
}

/// Health tab — unified health hub (dashboard + training).
class HealthTab extends StatelessWidget {
  const HealthTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const TrainingPage();
  }
}

/// Journey tab — sustainable wellbeing progression and camp.
class JourneyTab extends StatelessWidget {
  const JourneyTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const CharacterPage();
  }
}
