import 'package:kynos/domain/entities/coach/coach_context_preferences.dart';
import 'package:kynos/domain/entities/coach/coach_data_source.dart';
import 'package:kynos/domain/entities/coach/coach_tool_call.dart';
import 'package:kynos/domain/entities/health_summary.dart';
import 'package:kynos/domain/entities/workout_session.dart';
import 'package:kynos/domain/repositories/health_repository.dart';
import 'package:kynos/domain/utils/coach_tool_result_helpers.dart';
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
    final limit = CoachToolResultHelpers.intArg(call, 'limit', fallback: 5, min: 1, max: 10);
    final days = CoachToolResultHelpers.intArg(call, 'days', fallback: 30, min: 1, max: 90);
    final result = await _health.getRecentRuns(days: days, limit: limit);
    if (result.failure != null) {
      return CoachToolResultHelpers.error(call, 'Could not load recent runs.');
    }

    final runs = result.runs;
    if (runs.isEmpty) {
      return CoachToolResult(
        call: call,
        isError: false,
        promptSummary: 'No runs found in the last $days days.',
        displayLabel: 'No runs in $days days',
      );
    }

    final lines = runs.take(limit).map(_formatRunLine).join('\n');
    return CoachToolResult(
      call: call,
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
      final pace = formatPaceFromSession(
            duration: workout.duration,
            distanceMeters: workout.distanceMeters,
          ) ??
          'n/a';
      return CoachToolResult(
        call: call,
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
      call: call,
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
      return CoachToolResultHelpers.disabled(call, CoachDataSource.healthMetrics);
    }
    final metric = (CoachToolResultHelpers.stringArg(call, 'metric') ?? 'hrv').toLowerCase();
    final days = CoachToolResultHelpers.intArg(call, 'days', fallback: 14, min: 3, max: 60);
    final result = await _health.getSummaries(days: days);
    if (result.failure != null || result.summaries.isEmpty) {
      return CoachToolResultHelpers.error(call, 'No health data available for that range.');
    }

    final sorted = List<HealthSummary>.from(result.summaries)
      ..sort((a, b) => b.date.compareTo(a.date));
    final today = _metricValue(sorted.first, metric);
    final baseline = rollingAverage(sorted.skip(1).map((s) => _metricValue(s, metric)));
    final delta = computeMetricDelta(
      today: today,
      baseline: baseline,
      higherIsBetter: metric != 'rhr',
    );
    final unit = _metricUnit(metric);

    if (today == null) {
      return CoachToolResult(
        call: call,
        isError: false,
        promptSummary: 'No $metric readings in the last $days days.',
        displayLabel: '$metric trend unavailable',
      );
    }

    final trendPhrase = switch (delta?.direction) {
      null => '',
      _ when delta!.improved => ' Trending better.',
      _ => ' Trending worse.',
    };
    final baselineText = baseline == null ? 'n/a' : '${baseline.toStringAsFixed(1)}$unit';
    return CoachToolResult(
      call: call,
      isError: false,
      promptSummary: 'Latest $metric: ${today.toStringAsFixed(1)}$unit. '
          '$days-day avg: $baselineText.$trendPhrase',
      displayLabel: '$metric trend ($days d)',
    );
  }

  String _formatRunLine(WorkoutSession run) {
    final date = '${run.start.month}/${run.start.day}';
    final km = run.distanceMeters != null && run.distanceMeters! > 0
        ? '${(run.distanceMeters! / 1000).toStringAsFixed(1)}km'
        : '';
    final pace = formatPaceFromSession(
          duration: run.duration,
          distanceMeters: run.distanceMeters,
        ) ??
        '';
    final parts = [date, km, formatRunDuration(run.duration), pace].where((p) => p.isNotEmpty);
    return '- ${parts.join(' ')}';
  }

  double? _metricValue(HealthSummary summary, String metric) => switch (metric) {
        'hrv' => summary.hrvMs,
        'rhr' => summary.rhrBpm,
        'sleep' => summary.sleepHours,
        'steps' => summary.steps?.toDouble(),
        _ => summary.hrvMs,
      };

  String _metricUnit(String metric) => switch (metric) {
        'sleep' => 'h',
        'steps' => ' steps',
        'rhr' => 'bpm',
        _ => 'ms',
      };
}
