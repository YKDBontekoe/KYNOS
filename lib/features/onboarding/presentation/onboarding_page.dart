import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kynos/app/router.dart';
import 'package:kynos/core/theme/app_theme.dart';
import 'package:kynos/core/theme/spacing.dart';
import 'package:kynos/features/onboarding/providers/onboarding_provider.dart';

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

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar: Skip Button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(right: Spacing.md, top: Spacing.sm),
                child: TextButton(
                  onPressed: _finishOnboarding,
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.secondaryLabel,
                  ),
                  child: Text(
                    'Skip',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
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
              padding: const EdgeInsets.all(Spacing.xl),
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
                  const Gap(Spacing.xxl),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            flex: 3,
            child: Image.asset(
              item.imagePath,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stack) =>
                  const Icon(Icons.image_not_supported, size: 100, color: AppTheme.tertiaryLabel),
            ),
          ),
          const Gap(Spacing.xxl),
          Flexible(
            flex: 2,
            child: Column(
              children: [
                Text(
                  item.title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    color: AppTheme.label,
                  ),
                ),
                const Gap(Spacing.md),
                Text(
                  item.description,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: AppTheme.secondaryLabel,
                    height: 1.5,
                  ),
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
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      height: 8.0,
      width: isActive ? 24.0 : 8.0,
      decoration: BoxDecoration(
        color: isActive ? AppTheme.stand : AppTheme.tertiaryLabel,
        borderRadius: BorderRadius.circular(4.0),
      ),
    );
  }
}
