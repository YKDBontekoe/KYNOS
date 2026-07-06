import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:kynos/core/constants/gamification_constants.dart';
import 'package:kynos/core/theme/spacing.dart' as tokens;
import 'package:kynos/features/character/presentation/widgets/camp_build_sheet.dart';
import 'package:kynos/features/character/presentation/widgets/camp_grid.dart';
import 'package:kynos/features/character/presentation/widgets/camp_resources_bar.dart';
import 'package:kynos/features/character/presentation/widgets/expedition_card.dart';
import 'package:kynos/shared/providers/camp_providers.dart';
import 'package:kynos/shared/providers/health_providers.dart';
import 'package:kynos/shared/widgets/kynos_inline_error_card.dart';
import 'package:kynos/shared/widgets/kynos_skeleton.dart';

class CampGamePanel extends ConsumerStatefulWidget {
  const CampGamePanel({super.key});

  @override
  ConsumerState<CampGamePanel> createState() => _CampGamePanelState();
}

class _CampGamePanelState extends ConsumerState<CampGamePanel> {
  int? _selectedRow;
  int? _selectedCol;

  @override
  Widget build(BuildContext context) {
    final campAsync = ref.watch(campSessionProvider);
    final healthAsync = ref.watch(healthSummaryProvider);
    final runsAsync = ref.watch(recentRunsProvider(days: 1, limit: 5));

    return campAsync.when(
      loading: () => const Column(
        children: [
          KynosSkeleton.tile(height: 56),
          Gap(tokens.Spacing.sm),
          KynosSkeleton.tile(height: 280),
        ],
      ),
      error: (_, _) => KynosInlineErrorCard(
        message: 'Camp unavailable. Try again.',
        onRetry: () => ref.invalidate(campSessionProvider),
      ),
      data: (viewState) {
        if (viewState == null) return const SizedBox.shrink();

        final camp = viewState.camp;
        final resources = viewState.resources;
        final hasRunToday = runsAsync.maybeWhen(
          data: (runs) {
            final today = DateTime.now();
            return runs.any((r) {
              final d = r.start;
              return d.year == today.year &&
                  d.month == today.month &&
                  d.day == today.day;
            });
          },
          orElse: () => false,
        );

        return Column(
          children: [
            CampResourcesBar(
              resources: resources,
              isLoading: healthAsync.isLoading,
            ),
            const Gap(tokens.Spacing.sm),
            CampGrid(
              camp: camp,
              selectedRow: _selectedRow,
              selectedCol: _selectedCol,
              onTileTap: (row, col) => _onTileTap(
                context,
                viewState,
                row,
                col,
              ),
            ),
            const Gap(tokens.Spacing.sm),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: resources.canSpendFocus(
                      GamificationConstants.focusCostRest,
                    )
                        ? () => ref
                            .read(campSessionProvider.notifier)
                            .restCamp()
                        : null,
                    icon: const Icon(Icons.nightlight_round),
                    label: const Text(
                      'Rest (${GamificationConstants.focusCostRest} Focus)',
                    ),
                  ),
                ),
              ],
            ),
            const Gap(tokens.Spacing.sm),
            ExpeditionCard(
              resources: resources,
              expeditionUsedToday: camp.expeditionUsedToday,
              hasRunToday: hasRunToday,
              lastExpedition: viewState.lastExpedition,
              onLaunch: () =>
                  ref.read(campSessionProvider.notifier).launchExpedition(),
            ),
          ],
        );
      },
    );
  }

  Future<void> _onTileTap(
    BuildContext context,
    CampViewState viewState,
    int row,
    int col,
  ) async {
    setState(() {
      _selectedRow = row;
      _selectedCol = col;
    });

    await CampBuildSheet.show(
      context,
      camp: viewState.camp,
      row: row,
      col: col,
      availableFuel: viewState.resources.availableFuel,
      availableMomentum: viewState.resources.availableMomentum,
      onExpand: () async {
        Navigator.of(context).pop();
        await ref.read(campSessionProvider.notifier).expandTile(row, col);
      },
      onBuild: (type) async {
        Navigator.of(context).pop();
        await ref
            .read(campSessionProvider.notifier)
            .buildStructure(row: row, col: col, type: type);
      },
    );
  }
}
