import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:kynos/app/router.dart';
import 'package:kynos/core/theme/spacing.dart' as tokens;
import 'package:kynos/core/theme/theme.dart';

/// Friendly 404 page for unknown routes.
class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    final kynos = context.kynosTheme;
    return Scaffold(
      backgroundColor: kynos.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(tokens.Spacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.explore_off_outlined, size: 48, color: kynos.tertiaryLabel),
              const Gap(tokens.Spacing.lg),
              Text(
                'Page not found',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const Gap(tokens.Spacing.sm),
              Text(
                'The page you requested does not exist.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const Gap(tokens.Spacing.lg),
              FilledButton(
                onPressed: () => context.go(Routes.dashboard),
                child: const Text('Go to Today'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
