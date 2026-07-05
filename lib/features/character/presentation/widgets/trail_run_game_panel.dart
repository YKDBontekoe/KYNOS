import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:kynos/core/theme/spacing.dart' as tokens;
import 'package:kynos/features/character/presentation/widgets/activity_resources_bar.dart';
import 'package:kynos/features/character/presentation/widgets/encounter_panel.dart';
import 'package:kynos/features/character/presentation/widgets/trail_map.dart';
import 'package:kynos/features/character/providers/adventure_provider.dart';
import 'package:kynos/shared/widgets/kynos_loading_line.dart';
import 'package:kynos/shared/widgets/kynos_skeleton.dart';

class TrailRunGamePanel extends ConsumerWidget {
  const TrailRunGamePanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adventureAsync = ref.watch(adventureSessionProvider);

    return adventureAsync.when(
      loading: () => const Column(
        children: [
          KynosSkeleton.tile(height: 56),
          Gap(tokens.Spacing.sm),
          KynosSkeleton.tile(height: 160),
        ],
      ),
      error: (_, _) => const KynosLoadingLine(
        label: 'Trail unavailable',
      ),
      data: (viewState) {
        if (viewState == null) return const SizedBox.shrink();

        final session = viewState.session;
        final resources = viewState.resources;
        final encounter = session.activeEncounter;
        final inCombat = encounter?.isActive ?? false;

        return Column(
          children: [
            ActivityResourcesBar(resources: resources),
            const Gap(tokens.Spacing.sm),
            TrailMap(
              session: session,
              canAdvance: resources.canAdvance && !inCombat && !session.trailCompleted,
              onAdvance: () =>
                  ref.read(adventureSessionProvider.notifier).advance(),
            ),
            if (encounter != null && encounter.isActive) ...[
              const Gap(tokens.Spacing.sm),
              EncounterPanel(
                encounter: encounter,
                availableStamina: resources.availableStamina,
                onAction: (action) => ref
                    .read(adventureSessionProvider.notifier)
                    .performCombatAction(action),
                onRetreat: () => ref
                    .read(adventureSessionProvider.notifier)
                    .retreatFromEncounter(),
              ),
            ],
          ],
        );
      },
    );
  }
}
