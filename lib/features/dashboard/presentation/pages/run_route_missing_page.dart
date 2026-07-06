import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:kynos/app/router.dart';
import 'package:kynos/core/theme/spacing.dart' as tokens;
import 'package:kynos/core/theme/theme.dart';
import 'package:kynos/shared/utils/navigation_utils.dart';
import 'package:kynos/shared/widgets/kynos_card.dart';

/// Shown when `/run-route` is opened without a [WorkoutSession] in route extra.
class RunRouteMissingPage extends StatelessWidget {
  const RunRouteMissingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final kynos = context.kynosTheme;
    return Scaffold(
      backgroundColor: kynos.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => popOrGo(context, Routes.dashboard),
        ),
        title: const Text('Run Route'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(tokens.Spacing.md),
        child: KynosCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Run not found',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Gap(tokens.Spacing.sm),
              Text(
                'Open a run from your history to view its route in the app.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const Gap(tokens.Spacing.md),
              FilledButton(
                onPressed: () => context.go(Routes.runHistory),
                child: const Text('View run history'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
