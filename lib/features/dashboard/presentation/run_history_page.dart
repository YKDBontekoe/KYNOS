import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kynos/core/theme/app_theme.dart';
import 'package:kynos/core/theme/spacing.dart' as tokens;
import 'package:kynos/features/dashboard/providers/health_provider.dart';
import 'package:kynos/features/training/presentation/training_page.dart';

class RunHistoryPage extends ConsumerWidget {
  const RunHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final runsAsync = ref.watch(recentRunsProvider(days: 365, limit: 200));

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          SliverAppBar(
            backgroundColor: AppTheme.background,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            pinned: true,
            titleSpacing: 0,
            title: Text(
              'Run History',
              style: GoogleFonts.inter(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppTheme.label,
                letterSpacing: -0.3,
              ),
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
                        const Icon(
                          Icons.directions_run_rounded,
                          size: 48,
                          color: AppTheme.tertiaryLabel,
                        ),
                        const Gap(tokens.Spacing.md),
                        Text(
                          'No runs found',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.secondaryLabel,
                          ),
                        ),
                        const Gap(tokens.Spacing.xs),
                        Text(
                          'Complete a run and it will appear here.',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: AppTheme.tertiaryLabel,
                          ),
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
                  separatorBuilder: (context, index) => const Gap(tokens.Spacing.sm),
                  itemBuilder: (context, index) =>
                      RunCard(run: runs[index]),
                ),
              );
            },
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => SliverFillRemaining(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(tokens.Spacing.md),
                  child: Text(
                    'Failed to load runs: $e',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppTheme.secondaryLabel,
                    ),
                    textAlign: TextAlign.center,
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
