import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:kynos/app/router.dart';
import 'package:kynos/core/theme/spacing.dart' as tokens;
import 'package:kynos/core/theme/theme.dart' hide Radius, Spacing;
import 'package:kynos/features/onboarding/providers/onboarding_provider.dart';
import 'package:kynos/shared/widgets/liquid_glass_button.dart';

class OnboardingItem {
  final String imagePath;
  final String title;
  final String description;

  const OnboardingItem({
    required this.imagePath,
    required this.title,
    required this.description,
  });
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
      imagePath: 'assets/images/onboarding_biomechanics.png',
      title: 'Personalised Running',
      description: 'Train smarter with AI-driven insights that adapt to your unique biomechanics.',
    ),
    OnboardingItem(
      imagePath: 'assets/images/onboarding_privacy.png',
      title: 'Zero Knowledge Privacy',
      description: 'Your data stays on your device. Period. Powered by local AI and zk-SNARK proofs.',
    ),
    OnboardingItem(
      imagePath: 'assets/images/onboarding_health_data.png',
      title: 'Ready to go?',
      description: 'Get started and connect your health data to build your baseline.',
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

  void _finishOnboarding() {
    ref.read(onboardingCompletedProvider.notifier).completeOnboarding();
    context.go(Routes.dashboard);
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
            // Top Bar: Skip Button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(
                  right: tokens.Spacing.md,
                  top: tokens.Spacing.sm,
                ),
                child: LiquidGlassButton(
                  label: 'Skip',
                  onPressed: _finishOnboarding,
                ),
              ),
            ),

            // Middle: Scrollable PageView
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

            // Bottom: Indicators & Button
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
                      ),
                    ),
                  ),
                  const Gap(tokens.Spacing.xxl),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        if (isLastPage) {
                          _finishOnboarding();
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
  final OnboardingItem item;

  const _OnboardingPageWidget({required this.item});

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
  final bool isActive;
  const _DotIndicator({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
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
    );
  }
}
