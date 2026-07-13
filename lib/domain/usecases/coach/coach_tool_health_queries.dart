import 'package:kynos/domain/entities/coach/coach_context_preferences.dart';
import 'package:kynos/domain/entities/coach/coach_data_source.dart';
import 'package:kynos/domain/entities/coach/coach_tool_call.dart';
import 'package:kynos/domain/entities/health/health_coach_models.dart';
import 'package:kynos/domain/entities/health/health_metric.dart';
import 'package:kynos/domain/entities/health/health_visual_artifact.dart';
import 'package:kynos/domain/entities/health_summary.dart';
import 'package:kynos/domain/entities/workout_session.dart';
import 'package:kynos/domain/repositories/health_repository.dart';
import 'package:kynos/domain/utils/coach_tool_result_helpers.dart';
import 'package:kynos/domain/utils/health_coach_analysis.dart';
import 'package:kynos/domain/utils/metric_trends.dart';
import 'package:kynos/domain/utils/pace_format.dart';
import 'package:kynos/domain/utils/run_route_analytics.dart';

/// Coach agent tools that query [HealthRepository] directly for data outside
/// the static [CoachContext]'s default window (deeper run history, per-km
/// splits, custom-range trends).
class CoachToolHealthQueries {
  const CoachToolHealthQueries({required HealthRepository healthRepository})
    : _health = healthRepository;

  final HealthRepository _health;

  Future<CoachToolResult> getRecentRuns(
    CoachToolCall call,
    CoachContextPreferences prefs,
  ) async {
    if (!prefs.isEnabled(CoachDataSource.recentRuns)) {
      return CoachToolResultHelpers.disabled(call, CoachDataSource.recentRuns);
    }
    final limit = CoachToolResultHelpers.intArg(
      call,
      'limit',
      fallback: 5,
      min: 1,
      max: 10,
    );
    final days = CoachToolResultHelpers.intArg(
      call,
      'days',
      fallback: 30,
      min: 1,
      max: 90,
    );
    final result = await _health.getRecentRuns(days: days, limit: limit);
    if (result.failure != null) {
      return CoachToolResultHelpers.error(call, 'Could not load recent runs.');
    }

    final runs = result.runs;
    if (runs.isEmpty) {
      return CoachToolResult(
        toolCall: call,
        isError: false,
        promptSummary: 'No runs found in the last $days days.',
        displayLabel: 'No runs in $days days',
      );
    }

    final lines = runs.take(limit).map(_formatRunLine).join('\n');
    return CoachToolResult(
      toolCall: call,
      isError: false,
      promptSummary: 'Runs (last $days days):\n$lines',
      displayLabel: '${runs.length} run${runs.length == 1 ? '' : 's'} found',
    );
  }

  Future<CoachToolResult> getRunDetail(
    CoachToolCall call,
    CoachContextPreferences prefs,
  ) async {
    if (!prefs.isEnabled(CoachDataSource.recentRuns)) {
      return CoachToolResultHelpers.disabled(call, CoachDataSource.recentRuns);
    }
    final runId = CoachToolResultHelpers.stringArg(call, 'run_id');
    if (runId == null || runId.isEmpty) {
      return CoachToolResultHelpers.error(call, 'Missing run_id argument.');
    }

    final workoutResult = await _health.getWorkoutById(workoutId: runId);
    final workout = workoutResult.workout;
    if (workout == null) {
      return CoachToolResultHelpers.error(call, 'Run "$runId" was not found.');
    }

    final routeResult = await _health.getRunRoute(workoutUuid: runId);
    final analytics = computeRunRouteAnalytics(
      session: workout,
      points: routeResult.points,
    );

    if (!analytics.hasSplits) {
      final pace =
          formatPaceFromSession(
            duration: workout.duration,
            distanceMeters: workout.distanceMeters,
          ) ??
          'n/a';
      return CoachToolResult(
        toolCall: call,
        isError: false,
        promptSummary:
            'Run $runId: ${formatRunDuration(workout.duration)}, avg pace $pace. '
            'No per-km split data available for this run.',
        displayLabel: 'Run summary (no splits)',
      );
    }

    final splitLines = analytics.kilometerSplits
        .map((s) => 'km${s.kilometer} ${formatPacePerKm(s.paceSecondsPerKm)}')
        .join(', ');
    return CoachToolResult(
      toolCall: call,
      isError: false,
      promptSummary: 'Run $runId splits — $splitLines',
      displayLabel: '${analytics.kilometerSplits.length} km splits',
    );
  }

  Future<CoachToolResult> getHealthTrend(
    CoachToolCall call,
    CoachContextPreferences prefs,
  ) async {
    if (!prefs.isEnabled(CoachDataSource.healthMetrics)) {
      return CoachToolResultHelpers.disabled(
        call,
        CoachDataSource.healthMetrics,
      );
    }
    final metricArg =
        (CoachToolResultHelpers.stringArg(call, 'metric') ?? 'hrv')
            .toLowerCase();
    final healthMetric = _metricFromArg(metricArg);
    if (healthMetric == null) {
      return CoachToolResultHelpers.error(
        call,
        'Unsupported metric "$metricArg".',
      );
    }
    final days = CoachToolResultHelpers.intArg(
      call,
      'days',
      fallback: 14,
      min: 7,
      max: 90,
    );
    final result = await _health.getSummaries(days: days);
    if (result.failure != null || result.summaries.isEmpty) {
      return CoachToolResultHelpers.error(
        call,
        'No health data available for that range.',
      );
    }

    final sorted = List<HealthSummary>.from(result.summaries)
      ..sort((a, b) => b.date.compareTo(a.date));
    final today = healthMetric.valueFrom(sorted.first);
    final baseline = rollingAverage(sorted.skip(1).map(healthMetric.valueFrom));
    final delta = computeMetricDelta(
      today: today,
      baseline: baseline,
      higherIsBetter: healthMetric != HealthMetric.restingHeartRate,
    );
    final unit = healthMetric.unit;

    if (today == null) {
      return CoachToolResult(
        toolCall: call,
        isError: false,
        promptSummary:
            'No ${healthMetric.label} readings in the last $days days.',
        displayLabel: '${healthMetric.label} trend unavailable',
      );
    }

    final trendPhrase = switch (delta?.direction) {
      null => '',
      _ when delta!.improved => ' Trending better.',
      _ => ' Trending worse.',
    };
    final baselineText = baseline == null
        ? 'n/a'
        : '${baseline.toStringAsFixed(1)}$unit';
    final points = sorted.reversed
        .map(
          (item) => switch (healthMetric.valueFrom(item)) {
            final value? => HealthDataPoint(date: item.date, value: value),
            null => null,
          },
        )
        .whereType<HealthDataPoint>()
        .take(120)
        .toList();
    final start = points.isEmpty ? sorted.last.date : points.first.date;
    final end = points.isEmpty ? sorted.first.date : points.last.date;
    final artifact = HealthVisualArtifact.trend(
      meta: HealthArtifactMeta(
        id: '${call.name}_${healthMetric.name}_${DateTime.now().microsecondsSinceEpoch}',
        title: '${healthMetric.label} trend',
        explanation:
            'Your measured ${healthMetric.label.toLowerCase()} over $days days.',
        start: start,
        end: end,
        confidence: points.length >= 14
            ? FindingConfidence.high
            : FindingConfidence.low,
        evidenceReferences: const ['On-device health history'],
        limitations: points.length < 14
            ? ['Fewer than 14 observations are available.']
            : const [],
      ),
      series: [
        HealthSeries(
          id: healthMetric.name,
          label: healthMetric.label,
          metric: healthMetric,
          unit: unit,
          points: points,
          baseline: baseline,
        ),
      ],
    );
    return CoachToolResult(
      toolCall: call,
      isError: false,
      promptSummary:
          'Latest ${healthMetric.label}: ${today.toStringAsFixed(1)} $unit. '
          '$days-day avg: $baselineText.$trendPhrase',
      displayLabel: '${healthMetric.label} trend ($days d)',
      visualArtifacts: [artifact],
    );
  }

  Future<CoachToolResult> compareHealthPeriods(
    CoachToolCall call,
    CoachContextPreferences prefs,
  ) async {
    if (!prefs.isEnabled(CoachDataSource.healthMetrics)) {
      return CoachToolResultHelpers.disabled(
        call,
        CoachDataSource.healthMetrics,
      );
    }
    final metric = _metricFromArg(
      (CoachToolResultHelpers.stringArg(call, 'metric') ?? 'sleep')
          .toLowerCase(),
    );
    if (metric == null) {
      return CoachToolResultHelpers.error(call, 'Unsupported health metric.');
    }
    final days = CoachToolResultHelpers.intArg(
      call,
      'days',
      fallback: 7,
      min: 7,
      max: 30,
    );
    final result = await _health.getSummaries(days: days * 2);
    if (result.failure != null) {
      return CoachToolResultHelpers.error(
        call,
        'Could not load health history.',
      );
    }
    final sorted = List<HealthSummary>.from(result.summaries)
      ..sort((a, b) => b.date.compareTo(a.date));
    final current = sorted
        .take(days)
        .map(metric.valueFrom)
        .whereType<double>()
        .toList();
    final previous = sorted
        .skip(days)
        .take(days)
        .map(metric.valueFrom)
        .whereType<double>()
        .toList();
    if (current.isEmpty || previous.isEmpty) {
      return CoachToolResultHelpers.error(
        call,
        'Not enough data to compare periods.',
      );
    }
    final currentMedian = HealthCoachAnalysis.median(current);
    final previousMedian = HealthCoachAnalysis.median(previous);
    final change = previousMedian == 0
        ? 0.0
        : ((currentMedian - previousMedian) / previousMedian) * 100;
    final now = DateTime.now();
    final artifact = HealthVisualArtifact.comparisonTable(
      meta: HealthArtifactMeta(
        id: '${call.name}_${metric.name}_${now.microsecondsSinceEpoch}',
        title: '${metric.label}: period comparison',
        explanation: 'Median values for two adjacent $days-day periods.',
        start: now.subtract(Duration(days: days * 2)),
        end: now,
        confidence: current.length >= 7 && previous.length >= 7
            ? FindingConfidence.moderate
            : FindingConfidence.low,
        evidenceReferences: const ['On-device health history'],
      ),
      columns: const ['Period', 'Median', 'Observations'],
      rows: [
        HealthTableRow(
          label: 'Recent',
          values: ['$currentMedian ${metric.unit}', '${current.length}'],
        ),
        HealthTableRow(
          label: 'Previous',
          values: ['$previousMedian ${metric.unit}', '${previous.length}'],
        ),
      ],
    );
    return CoachToolResult(
      toolCall: call,
      isError: false,
      promptSummary:
          '${metric.label} median changed ${change.toStringAsFixed(0)}% between the two periods. '
          'This is an observation, not a diagnosis.',
      displayLabel: 'Compared ${metric.label.toLowerCase()}',
      visualArtifacts: [artifact],
    );
  }

  Future<CoachToolResult> findMetricAssociation(
    CoachToolCall call,
    CoachContextPreferences prefs,
  ) async {
    if (!prefs.isEnabled(CoachDataSource.healthMetrics)) {
      return CoachToolResultHelpers.disabled(
        call,
        CoachDataSource.healthMetrics,
      );
    }
    final xMetric = _metricFromArg(
      (CoachToolResultHelpers.stringArg(call, 'x_metric') ?? 'sleep')
          .toLowerCase(),
    );
    final yMetric = _metricFromArg(
      (CoachToolResultHelpers.stringArg(call, 'y_metric') ?? 'hrv')
          .toLowerCase(),
    );
    if (xMetric == null || yMetric == null || xMetric == yMetric) {
      return CoachToolResultHelpers.error(
        call,
        'Choose two different supported metrics.',
      );
    }
    final days = CoachToolResultHelpers.intArg(
      call,
      'days',
      fallback: 30,
      min: 14,
      max: 90,
    );
    final result = await _health.getSummaries(days: days);
    final paired = HealthCoachAnalysis.pairedValues(
      result.summaries,
      xMetric,
      yMetric,
    );
    final coefficient = HealthCoachAnalysis.spearman(
      paired.map((point) => (x: point.x, y: point.y)).toList(),
    );
    if (coefficient == null) {
      return CoachToolResult(
        toolCall: call,
        isError: false,
        promptSummary:
            'No meaningful association could be supported between ${xMetric.label} and ${yMetric.label}.',
        displayLabel: 'No supported association',
      );
    }
    final now = DateTime.now();
    final strength = HealthCoachAnalysis.associationStrength(coefficient);
    final artifact = HealthVisualArtifact.correlationScatter(
      meta: HealthArtifactMeta(
        id: '${call.name}_${now.microsecondsSinceEpoch}',
        title: '${xMetric.label} and ${yMetric.label}',
        explanation:
            'A $strength observed association. This does not establish causation.',
        start: now.subtract(Duration(days: days)),
        end: now,
        confidence: paired.length >= 20
            ? FindingConfidence.moderate
            : FindingConfidence.low,
        evidenceReferences: ['${paired.length} paired observations'],
        limitations: const ['Association does not prove cause and effect.'],
      ),
      xMetric: xMetric,
      yMetric: yMetric,
      points: paired
          .take(120)
          .map(
            (point) =>
                HealthScatterPoint(date: point.date, x: point.x, y: point.y),
          )
          .toList(),
      correlation: coefficient,
    );
    return CoachToolResult(
      toolCall: call,
      isError: false,
      promptSummary:
          'A $strength ${coefficient >= 0 ? 'positive' : 'negative'} association was observed '
          'between ${xMetric.label} and ${yMetric.label} across ${paired.length} paired days. '
          'This does not establish causation.',
      displayLabel: 'Checked a health association',
      visualArtifacts: [artifact],
    );
  }

  Future<CoachToolResult> buildHealthTimeline(
    CoachToolCall call,
    CoachContextPreferences prefs,
  ) async {
    if (!prefs.isEnabled(CoachDataSource.healthMetrics)) {
      return CoachToolResultHelpers.disabled(
        call,
        CoachDataSource.healthMetrics,
      );
    }
    final days = CoachToolResultHelpers.intArg(
      call,
      'days',
      fallback: 14,
      min: 7,
      max: 60,
    );
    final result = await _health.getSummaries(days: days);
    final events = <HealthTimelineEvent>[];
    for (final item in result.summaries) {
      final sleep = item.sleepHours;
      final exercise = item.exerciseMinutes;
      if (sleep != null) {
        events.add(
          HealthTimelineEvent(
            date: item.date,
            title: 'Sleep',
            detail: '${sleep.toStringAsFixed(1)} h',
          ),
        );
      }
      if (exercise != null && exercise > 0) {
        events.add(
          HealthTimelineEvent(
            date: item.date,
            title: 'Movement',
            detail: '${exercise.round()} exercise min',
          ),
        );
      }
    }
    final now = DateTime.now();
    return CoachToolResult(
      toolCall: call,
      isError: false,
      promptSummary:
          'Built a $days-day health timeline with ${events.length} measured events.',
      displayLabel: 'Built your health timeline',
      visualArtifacts: [
        HealthVisualArtifact.healthTimeline(
          meta: HealthArtifactMeta(
            id: '${call.name}_${now.microsecondsSinceEpoch}',
            title: 'Health timeline',
            explanation:
                'Sleep and movement events from on-device health data.',
            start: now.subtract(Duration(days: days)),
            end: now,
            confidence: FindingConfidence.moderate,
            evidenceReferences: const ['On-device health history'],
          ),
          events: events.take(120).toList(),
        ),
      ],
    );
  }

  String _formatRunLine(WorkoutSession run) {
    final date = '${run.start.month}/${run.start.day}';
    final km = run.distanceMeters != null && run.distanceMeters! > 0
        ? '${(run.distanceMeters! / 1000).toStringAsFixed(1)}km'
        : '';
    final pace =
        formatPaceFromSession(
          duration: run.duration,
          distanceMeters: run.distanceMeters,
        ) ??
        '';
    final parts = [
      date,
      km,
      formatRunDuration(run.duration),
      pace,
    ].where((p) => p.isNotEmpty);
    return '- ${parts.join(' ')}';
  }

  HealthMetric? _metricFromArg(String value) => switch (value) {
    'hrv' => HealthMetric.hrv,
    'rhr' || 'resting_heart_rate' => HealthMetric.restingHeartRate,
    'heart_rate' || 'average_heart_rate' => HealthMetric.averageHeartRate,
    'respiratory_rate' => HealthMetric.respiratoryRate,
    'blood_oxygen' || 'spo2' => HealthMetric.bloodOxygen,
    'sleep' => HealthMetric.sleep,
    'steps' => HealthMetric.steps,
    'distance' => HealthMetric.distance,
    'exercise' || 'exercise_time' => HealthMetric.exerciseTime,
    'active_energy' => HealthMetric.activeEnergy,
    'total_energy' => HealthMetric.totalEnergy,
    _ => null,
  };
}
