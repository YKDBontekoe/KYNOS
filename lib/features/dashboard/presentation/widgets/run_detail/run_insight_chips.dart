import 'package:flutter/material.dart';
import 'package:kynos/core/theme/spacing.dart' as tokens;
import 'package:kynos/core/theme/theme.dart';
import 'package:kynos/domain/entities/workout_route_point.dart';
import 'package:kynos/domain/entities/workout_session.dart';
import 'package:kynos/domain/utils/pace_format.dart';
import 'package:kynos/domain/utils/run_route_analytics.dart';
import 'package:kynos/shared/widgets/kynos_chip.dart';

/// Contextual insight chips for a run detail screen.
class RunInsightChips extends StatelessWidget {
  const RunInsightChips({
    super.key,
    required this.run,
    required this.analytics,
    required this.points,
  });

  final WorkoutSession run;
  final RunRouteAnalytics analytics;
  final List<WorkoutRoutePoint> points;

  @override
  Widget build(BuildContext context) {
    final kynos = context.kynosTheme;
    final chips = <Widget>[
      KynosChip.metric(label: 'Source', value: run.sourceName),
    ];

    final fastest = analytics.fastestSplitIndex;
    if (fastest != null && analytics.kilometerSplits.length > 1) {
      final split = analytics.kilometerSplits[fastest];
      chips.add(
        KynosChip.metric(
          label: 'Fastest km',
          value: formatPacePerKm(split.paceSecondsPerKm),
          color: kynos.exercise,
        ),
      );
    }

    final consistency = paceConsistencyScore(analytics.kilometerSplits);
    if (consistency != null) {
      final label = consistency < 0.04
          ? 'Steady pacing'
          : consistency < 0.08
              ? 'Moderate variation'
              : 'Uneven pacing';
      chips.add(KynosChip(label: label));
    }

    final recorded = run.distanceMeters;
    final gps = analytics.gpsDistanceMeters;
    if (recorded != null && gps > 0) {
      final deltaPct = ((gps - recorded) / recorded * 100).abs();
      if (deltaPct >= 3) {
        chips.add(
          KynosChip.metric(
            label: 'GPS vs recorded',
            value: '${deltaPct.toStringAsFixed(0)}% diff',
          ),
        );
      }
    }

    if (points.isNotEmpty) {
      chips.add(
        KynosChip.metric(
          label: 'Route points',
          value: points.length.toString(),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: tokens.Spacing.md),
      child: Wrap(
        spacing: tokens.Spacing.sm,
        runSpacing: tokens.Spacing.xs,
        children: chips,
      ),
    );
  }
}
