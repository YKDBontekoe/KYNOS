import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:kynos/core/theme/spacing.dart' as tokens;
import 'package:kynos/core/theme/theme.dart';
import 'package:kynos/domain/entities/workout_session.dart';
import 'package:kynos/domain/utils/pace_format.dart';
import 'package:kynos/domain/utils/run_route_analytics.dart';
import 'package:kynos/shared/widgets/metric_tile.dart';

/// Summary metric grid for the run detail screen.
class RunSummaryMetrics extends StatelessWidget {
  const RunSummaryMetrics({
    super.key,
    required this.run,
    required this.analytics,
  });

  final WorkoutSession run;
  final RunRouteAnalytics analytics;

  @override
  Widget build(BuildContext context) {
    final kynos = context.kynosTheme;
    final distanceKm = run.distanceMeters == null
        ? null
        : (run.distanceMeters! / 1000).toStringAsFixed(2);
    final pace = analytics.avgPaceSecondsPerKm == null
        ? null
        : formatPacePerKm(analytics.avgPaceSecondsPerKm!);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: tokens.Spacing.md),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: MetricTile(
                  label: 'Distance',
                  value: distanceKm,
                  unit: distanceKm == null ? null : 'km',
                  accentColor: kynos.stand,
                ),
              ),
              const Gap(tokens.Spacing.sm),
              Expanded(
                child: MetricTile(
                  label: 'Duration',
                  value: formatRunDuration(run.duration),
                  accentColor: kynos.exercise,
                ),
              ),
            ],
          ),
          const Gap(tokens.Spacing.sm),
          Row(
            children: [
              Expanded(
                child: MetricTile(
                  label: 'Avg Pace',
                  value: pace,
                  accentColor: kynos.energy,
                ),
              ),
              const Gap(tokens.Spacing.sm),
              Expanded(
                child: MetricTile(
                  label: 'Calories',
                  value: run.energyKcal == null
                      ? '—'
                      : run.energyKcal!.round().toString(),
                  unit: run.energyKcal == null ? null : 'kcal',
                  accentColor: kynos.purple,
                ),
              ),
            ],
          ),
          if (run.steps != null) ...[
            const Gap(tokens.Spacing.sm),
            MetricTile(
              label: 'Steps',
              value: run.steps!.toString(),
              accentColor: kynos.move,
              flat: true,
            ),
          ],
        ],
      ),
    );
  }
}
