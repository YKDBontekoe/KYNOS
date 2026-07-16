import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:kynos/app/router.dart';
import 'package:kynos/core/theme/spacing.dart' as tokens;
import 'package:kynos/core/theme/theme.dart';
import 'package:kynos/features/onboarding/providers/onboarding_provider.dart';
import 'package:kynos/shared/providers/health_providers.dart';
import 'package:kynos/shared/widgets/liquid_glass_button.dart';

class OnboardingItem {
  const OnboardingItem({
    required this.imagePath,
    required this.title,
    required this.description,
  });

  final String imagePath;
  final String title;
  final String description;
}

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  late PageController _pageController;
  int _currentIndex = 0;

  final List<OnboardingItem> items = const [
    OnboardingItem(
      imagePath: 'assets/images/onboarding_health_data.png',
      title: 'Your Coach Starts Here',
      description:
          'Open KYNOS to a clear session for today — not a dashboard of charts. '
          'Connect health data so the coach can prescribe with real signals.',
    ),
    OnboardingItem(
      imagePath: 'assets/images/onboarding_privacy.png',
      title: 'Private by Default',
      description:
          'Your health history, check-ins, experiments, and coach memory stay on your device.',
    ),
    OnboardingItem(
      imagePath: 'assets/images/onboarding_health_data.png',
      title: 'Learn Your Own Normal',
      description:
          'KYNOS learns your personal baseline instead of judging you against generic targets.',
    ),
    OnboardingItem(
      imagePath: 'assets/images/onboarding_biomechanics.png',
      title: 'One Useful Action',
      description:
          'Get a calm daily brief, investigate patterns visually, and try small changes only when you confirm them.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _finishOnboarding() async {
    await ref.read(onboardingCompletedProvider.notifier).completeOnboarding();
    if (!mounted) return;
    context.go(Routes.dashboard);
  }

  Future<void> _skipOnboarding() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Skip setup?'),
        content: const Text(
          'You can connect health data and set up the AI coach anytime in Settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Continue setup'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Skip for now'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    await _finishOnboarding();
  }

  Future<void> _getStarted() async {
    if (!kIsWeb) {
      await ref.read(healthPermissionsProvider.notifier).request();
    }
    if (!mounted) return;
    await ref.read(onboardingCompletedProvider.notifier).completeOnboarding();
    if (!mounted) return;
    context.go(Routes.healthImport);
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = _currentIndex == items.length - 1;
    final kynos = context.kynosTheme;

    return Scaffold(
      backgroundColor: kynos.background,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(
                  right: tokens.Spacing.md,
                  top: tokens.Spacing.sm,
                ),
                child: LiquidGlassButton(
                  label: 'Skip',
                  onPressed: _skipOnboarding,
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: items.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  return _OnboardingPageWidget(item: items[index]);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(tokens.Spacing.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      items.length,
                      (index) => _DotIndicator(
                        isActive: index == _currentIndex,
                        index: index,
                        total: items.length,
                      ),
                    ),
                  ),
                  const Gap(tokens.Spacing.xxl),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        if (isLastPage) {
                          _getStarted();
                        } else {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      child: Text(isLastPage ? 'Get Started' : 'Next'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPageWidget extends StatelessWidget {
  const _OnboardingPageWidget({required this.item});

  final OnboardingItem item;

  @override
  Widget build(BuildContext context) {
    final kynos = context.kynosTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: tokens.Spacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            flex: 3,
            child: Image.asset(
              item.imagePath,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stack) => Icon(
                Icons.image_not_supported,
                size: tokens.Spacing.xxxl,
                color: context.kynosTheme.tertiaryLabel,
              ),
            ),
          ),
          const Gap(tokens.Spacing.xxl),
          Flexible(
            flex: 2,
            child: Column(
              children: [
                Text(
                  item.title,
                  textAlign: TextAlign.center,
                  style: kynos.onboardingTitleStyle,
                ),
                const Gap(tokens.Spacing.md),
                Text(
                  item.description,
                  textAlign: TextAlign.center,
                  style: kynos.onboardingBodyStyle,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DotIndicator extends StatelessWidget {
  const _DotIndicator({
    required this.isActive,
    required this.index,
    required this.total,
  });

  final bool isActive;
  final int index;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Page ${index + 1} of $total',
      selected: isActive,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.symmetric(horizontal: tokens.Spacing.xs),
        height: tokens.Spacing.sm,
        width: isActive ? tokens.Spacing.lg : tokens.Spacing.sm,
        decoration: BoxDecoration(
          color: isActive
              ? context.kynosTheme.stand
              : context.kynosTheme.tertiaryLabel,
          borderRadius: BorderRadius.circular(tokens.Radius.sm),
        ),
      ),
    );
  }
}
