import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:kynos/app/router.dart';
import 'package:kynos/core/theme/spacing.dart' as tokens;
import 'package:kynos/core/theme/theme.dart';
import 'package:kynos/shared/providers/health_providers.dart';
import 'package:kynos/shared/widgets/kynos_skeleton.dart';
import 'package:kynos/shared/widgets/run_card.dart';

class RunHistoryPage extends ConsumerWidget {
  const RunHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kynos = context.kynosTheme;
    final runsAsync = ref.watch(recentRunsProvider(days: 365, limit: 200));

    return Scaffold(
      backgroundColor: kynos.background,
      body: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          SliverAppBar(
            backgroundColor: kynos.background,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            pinned: true,
            titleSpacing: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go(Routes.dashboard);
                }
              },
            ),
            title: Text(
              'Run History',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          runsAsync.when(
            data: (runs) {
              if (runs.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.directions_run_rounded,
                          size: 48,
                          color: kynos.tertiaryLabel,
                        ),
                        const Gap(tokens.Spacing.md),
                        Text(
                          'No runs found',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const Gap(tokens.Spacing.xs),
                        Text(
                          'Import Apple Health export.zip or log a run manually in Settings.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: kynos.tertiaryLabel,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const Gap(tokens.Spacing.sm),
                        TextButton(
                          onPressed: () => context.push(Routes.healthImport),
                          child: const Text('Import a run'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  tokens.Spacing.md,
                  tokens.Spacing.sm,
                  tokens.Spacing.md,
                  tokens.Spacing.xl,
                ),
                sliver: SliverList.separated(
                  itemCount: runs.length,
                  separatorBuilder: (context, index) =>
                      const Gap(tokens.Spacing.sm),
                  itemBuilder: (context, index) => RunCard(run: runs[index]),
                ),
              );
            },
            loading: () => const SliverFillRemaining(
              child: Padding(
                padding: EdgeInsets.all(tokens.Spacing.md),
                child: Column(
                  children: [
                    KynosSkeleton.tile(height: 120),
                    Gap(tokens.Spacing.sm),
                    KynosSkeleton.tile(height: 120),
                    Gap(tokens.Spacing.sm),
                    KynosSkeleton.tile(height: 120),
                  ],
                ),
              ),
            ),
            error: (e, _) => SliverFillRemaining(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(tokens.Spacing.md),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Failed to load runs: $e',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: kynos.secondaryLabel,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const Gap(tokens.Spacing.md),
                      FilledButton(
                        onPressed: () => ref.invalidate(
                          recentRunsProvider(days: 365, limit: 200),
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
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
