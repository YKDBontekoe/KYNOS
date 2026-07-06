import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kynos/app/router.dart';
import 'package:kynos/core/theme/spacing.dart' as tokens;
import 'package:kynos/domain/entities/workout_session.dart';
import 'package:kynos/shared/widgets/charts/chart_placeholder.dart';
import 'package:kynos/shared/widgets/kynos_card.dart';
import 'package:kynos/shared/widgets/run_card.dart';

/// Recent completed runs from HealthKit and imported sources.
class PastRunsList extends StatelessWidget {
  const PastRunsList({
    super.key,
    required this.runs,
    this.onAskCoach,
  });

  final List<WorkoutSession> runs;
  final void Function(WorkoutSession run, String seed)? onAskCoach;

  @override
  Widget build(BuildContext context) {
    if (runs.isEmpty) {
      return KynosCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ChartPlaceholder(
              label: 'No completed runs found yet',
            ),
            TextButton(
              onPressed: () => context.push(Routes.healthImport),
              child: const Text('Import a run'),
            ),
          ],
        ),
      );
    }
    return Column(
      children: runs
          .take(8)
          .map(
            (run) => Padding(
              padding: const EdgeInsets.only(bottom: tokens.Spacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RunCard(run: run),
                  if (onAskCoach != null)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          final km = (run.distanceMeters ?? 0) / 1000;
                          onAskCoach!(
                            run,
                            'Review my run on ${run.start.month}/${run.start.day}: '
                            '${km.toStringAsFixed(1)} km in '
                            '${run.duration.inMinutes} minutes. '
                            'What should I take away from this session?',
                          );
                        },
                        child: const Text('Ask about this run'),
                      ),
                    ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}
