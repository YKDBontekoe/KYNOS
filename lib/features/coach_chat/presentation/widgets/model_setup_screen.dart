import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:kynos/core/theme/theme.dart';
import 'package:kynos/shared/widgets/kynos_skeleton.dart';

class ModelSetupScreen extends StatelessWidget {
  const ModelSetupScreen({
    super.key,
    this.title,
    this.subtitle,
    this.onRetry,
    this.isLoading = false,
  });

  final String? title;
  final String? subtitle;
  final VoidCallback? onRetry;
  final bool isLoading;

  factory ModelSetupScreen.checking() => const ModelSetupScreen(
        title: 'Preparing AI Coach',
        subtitle: 'Checking for model...',
        isLoading: true,
      );

  factory ModelSetupScreen.error({
    required String message,
    required VoidCallback onRetry,
  }) =>
      ModelSetupScreen(
        title: 'Setup Failed',
        subtitle: message,
        onRetry: onRetry,
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.kynosTheme.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(Spacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isLoading)
                const KynosSkeleton(height: 48, width: 48)
              else
                Icon(Icons.error_outline, size: 48, color: context.kynosTheme.move),
              const Gap(Spacing.lg),
              Text(
                title ?? '',
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const Gap(Spacing.sm),
              Text(
                subtitle ?? '',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              if (onRetry != null) ...[
                const Gap(Spacing.lg),
                FilledButton(
                  onPressed: onRetry,
                  child: const Text('Try Again'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
