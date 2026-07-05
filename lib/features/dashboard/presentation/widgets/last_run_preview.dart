import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:kynos/app/router.dart';
import 'package:kynos/core/theme/theme.dart';
import 'package:kynos/domain/entities/workout_session.dart';
import 'package:kynos/shared/widgets/kynos_card.dart';
import 'package:kynos/shared/widgets/kynos_loading_line.dart';
import 'package:kynos/shared/widgets/run_card.dart';

/// Shows the most recent run on the Today tab.
class LastRunPreview extends StatelessWidget {
  const LastRunPreview({
    super.key,
    required this.runsAsync,
  });

  final AsyncValue<List<WorkoutSession>> runsAsync;

  @override
  Widget build(BuildContext context) {
    return runsAsync.when(
      loading: () => const KynosCard(
        child: KynosLoadingLine(label: 'Loading recent run...'),
      ),
      error: (_, _) => KynosCard(
        child: Text(
          'Could not load recent runs.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
      data: (runs) {
        if (runs.isEmpty) {
          return KynosCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'No runs recorded yet this month.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: context.kynosTheme.secondaryLabel,
                      ),
                ),
                const Gap(Spacing.sm),
                TextButton(
                  onPressed: () => context.push(Routes.healthImport),
                  child: const Text('Import a run'),
                ),
              ],
            ),
          );
        }
        return RunCard(run: runs.first);
      },
    );
  }
}
