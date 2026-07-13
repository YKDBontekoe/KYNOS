import 'package:kynos/domain/entities/coach/coach_context.dart';
import 'package:kynos/domain/entities/coach/coach_context_preferences.dart';
import 'package:kynos/domain/entities/coach/coach_data_source.dart';
import 'package:kynos/domain/entities/coach/coach_tool_call.dart';
import 'package:kynos/domain/entities/health/health_coach_models.dart';
import 'package:kynos/domain/entities/health/health_metric.dart';
import 'package:kynos/domain/entities/health/health_visual_artifact.dart';
import 'package:kynos/domain/entities/health_summary.dart';
import 'package:kynos/domain/utils/coach_tool_result_helpers.dart';

class CoachToolWellbeingQueries {
  const CoachToolWellbeingQueries();

  CoachToolResult getDailyHealthBrief(
    CoachToolCall call,
    CoachContext context,
    CoachContextPreferences prefs,
  ) {
    if (!prefs.isEnabled(CoachDataSource.healthMetrics)) {
      return CoachToolResultHelpers.disabled(
        call,
        CoachDataSource.healthMetrics,
      );
    }
    final brief = context.dailyHealthBrief;
    if (brief == null) {
      return CoachToolResultHelpers.error(
        call,
        'The daily health brief is unavailable.',
      );
    }
    final evidence = brief.findings
        .expand((finding) => finding.evidence)
        .take(4)
        .join('; ');
    return CoachToolResult(
      toolCall: call,
      isError: false,
      promptSummary:
          '${brief.bodyStateSummary} Suggested action: ${brief.primaryAction} '
          '${evidence.isEmpty ? '' : 'Evidence: $evidence'}',
      displayLabel: 'Reviewed today’s health brief',
      findings: brief.findings,
    );
  }

  CoachToolResult getCheckInHistory(
    CoachToolCall call,
    CoachContext context,
    CoachContextPreferences prefs,
  ) {
    if (!prefs.isEnabled(CoachDataSource.healthCheckIns)) {
      return CoachToolResultHelpers.disabled(
        call,
        CoachDataSource.healthCheckIns,
      );
    }
    final days = CoachToolResultHelpers.intArg(
      call,
      'days',
      fallback: 14,
      min: 7,
      max: 60,
    );
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final cutoff = today.subtract(Duration(days: days - 1));
    final checkIns =
        context.healthCheckIns
            .where((item) => !item.date.isBefore(cutoff))
            .take(60)
            .toList()
          ..sort((a, b) => a.date.compareTo(b.date));
    if (checkIns.isEmpty) {
      return CoachToolResult(
        toolCall: call,
        isError: false,
        promptSummary: 'No subjective check-ins are available for this period.',
        displayLabel: 'No check-ins yet',
      );
    }
    final start = checkIns.first.date;
    final end = checkIns.last.date;
    final artifact = HealthVisualArtifact.trend(
      meta: HealthArtifactMeta(
        id: '${call.name}_${DateTime.now().microsecondsSinceEpoch}',
        title: 'How you have felt',
        explanation: 'Your self-reported energy, mood, and stress.',
        start: start,
        end: end,
        confidence: FindingConfidence.high,
        evidenceReferences: ['${checkIns.length} self-reported check-ins'],
      ),
      series: [
        _checkInSeries(
          checkIns,
          HealthMetric.selfReportedEnergy,
          (item) => item.energy,
        ),
        _checkInSeries(
          checkIns,
          HealthMetric.selfReportedMood,
          (item) => item.mood,
        ),
        _checkInSeries(
          checkIns,
          HealthMetric.selfReportedStress,
          (item) => item.stress,
        ),
      ],
    );
    return CoachToolResult(
      toolCall: call,
      isError: false,
      promptSummary:
          '${checkIns.length} self-reported check-ins are available. '
          'Treat these as the person’s lived experience, not sensor measurements.',
      displayLabel: 'Reviewed your check-ins',
      visualArtifacts: [artifact],
    );
  }

  CoachToolResult getExperimentStatus(
    CoachToolCall call,
    CoachContext context,
    CoachContextPreferences prefs,
  ) {
    if (!prefs.isEnabled(CoachDataSource.wellbeingExperiments)) {
      return CoachToolResultHelpers.disabled(
        call,
        CoachDataSource.wellbeingExperiments,
      );
    }
    final experiments = context.wellbeingExperiments;
    if (experiments.isEmpty) {
      return CoachToolResult(
        toolCall: call,
        isError: false,
        promptSummary: 'No wellbeing experiments have been confirmed.',
        displayLabel: 'No active experiments',
      );
    }
    final rows = experiments.take(10).map((experiment) {
      final adhered = experiment.logs.where((log) => log.adhered).length;
      return HealthTableRow(
        label: experiment.title,
        values: [experiment.status.name, '$adhered/${experiment.logs.length}'],
      );
    }).toList();
    final now = DateTime.now();
    return CoachToolResult(
      toolCall: call,
      isError: false,
      promptSummary:
          '${experiments.length} experiment${experiments.length == 1 ? '' : 's'} found. '
          'Only confirmed experiments are active.',
      displayLabel: 'Reviewed wellbeing experiments',
      visualArtifacts: [
        HealthVisualArtifact.comparisonTable(
          meta: HealthArtifactMeta(
            id: '${call.name}_${now.microsecondsSinceEpoch}',
            title: 'Wellbeing experiments',
            explanation:
                'Status and recorded adherence for confirmed experiments.',
            start: experiments.last.createdAt,
            end: now,
            confidence: FindingConfidence.high,
            evidenceReferences: const ['Locally stored experiment logs'],
          ),
          columns: const ['Experiment', 'Status', 'Recorded days'],
          rows: rows,
        ),
      ],
    );
  }

  CoachToolResult compareHighLowDays(
    CoachToolCall call,
    CoachContext context,
    CoachContextPreferences prefs,
  ) {
    if (!prefs.isEnabled(CoachDataSource.healthCheckIns) ||
        !prefs.isEnabled(CoachDataSource.healthMetrics)) {
      return CoachToolResultHelpers.error(
        call,
        'Health metrics and daily check-ins must both be enabled.',
      );
    }
    final summaries = {
      for (final item in context.healthHistory)
        DateTime(item.date.year, item.date.month, item.date.day): item,
    };
    final high = context.healthCheckIns
        .where((item) => item.energy >= 4)
        .toList();
    final low = context.healthCheckIns
        .where((item) => item.energy <= 2)
        .toList();
    if (high.length < 2 || low.length < 2) {
      return CoachToolResult(
        toolCall: call,
        isError: false,
        promptSummary:
            'At least two high-energy and two low-energy check-in days are needed.',
        displayLabel: 'More check-ins needed',
      );
    }
    final rows = <HealthTableRow>[];
    var pairedHighCount = 0;
    var pairedLowCount = 0;
    for (final metric in const [
      HealthMetric.sleep,
      HealthMetric.hrv,
      HealthMetric.steps,
    ]) {
      final highValues = _valuesForCheckIns(high, summaries, metric);
      final lowValues = _valuesForCheckIns(low, summaries, metric);
      if (highValues.length < 2 || lowValues.length < 2) continue;
      pairedHighCount += highValues.length;
      pairedLowCount += lowValues.length;
      rows.add(
        HealthTableRow(
          label: metric.label,
          values: [
            '${_mean(highValues).toStringAsFixed(1)} ${metric.unit}',
            '${_mean(lowValues).toStringAsFixed(1)} ${metric.unit}',
          ],
        ),
      );
    }
    if (rows.isEmpty) {
      return CoachToolResultHelpers.error(
        call,
        'Check-in days could not be paired with measured health data.',
      );
    }
    final dates = [...high, ...low].map((item) => item.date).toList()..sort();
    return CoachToolResult(
      toolCall: call,
      isError: false,
      promptSummary:
          'Compared measured signals from $pairedHighCount high-energy and '
          '$pairedLowCount low-energy paired observations. '
          'Differences are descriptive associations only.',
      displayLabel: 'Compared high- and low-energy days',
      visualArtifacts: [
        HealthVisualArtifact.comparisonTable(
          meta: HealthArtifactMeta(
            id: '${call.name}_${DateTime.now().microsecondsSinceEpoch}',
            title: 'High- and low-energy days',
            explanation:
                'Average measured signals grouped by your energy check-ins.',
            start: dates.first,
            end: dates.last,
            confidence: FindingConfidence.low,
            evidenceReferences: [
              '${pairedHighCount + pairedLowCount} paired metric observations',
            ],
            limitations: const [
              'These differences do not establish cause and effect.',
            ],
          ),
          columns: const ['Signal', 'High-energy days', 'Low-energy days'],
          rows: rows,
        ),
      ],
    );
  }

  CoachToolResult proposeExperiment(CoachToolCall call) {
    final title = CoachToolResultHelpers.stringArg(call, 'title')?.trim();
    final actionId = CoachToolResultHelpers.stringArg(
      call,
      'action_id',
    )?.trim();
    final hypothesis = CoachToolResultHelpers.stringArg(
      call,
      'hypothesis',
    )?.trim();
    final duration = CoachToolResultHelpers.intArg(
      call,
      'duration_days',
      fallback: 7,
      min: 3,
      max: 14,
    );
    if (title == null || title.isEmpty || actionId == null) {
      return CoachToolResultHelpers.error(
        call,
        'A title and one low-risk action are required.',
      );
    }
    final action = _safeExperimentCatalog[actionId];
    if (action == null) {
      return CoachToolResultHelpers.error(
        call,
        'That experiment is outside the low-risk wellbeing catalog.',
      );
    }
    final pending = PendingCoachAction(
      id: 'experiment_${DateTime.now().microsecondsSinceEpoch}',
      type: CoachActionType.createExperiment,
      title: title,
      explanation: hypothesis?.isNotEmpty == true
          ? hypothesis!
          : 'Notice whether this small change affects how you feel.',
      payload: {'action': action, 'durationDays': duration},
    );
    return CoachToolResult(
      toolCall: call,
      isError: false,
      promptSummary:
          'A $duration-day wellbeing experiment was proposed. It is not active until the user confirms it.',
      displayLabel: 'Prepared an experiment proposal',
      pendingActions: [pending],
    );
  }

  CoachToolResult proposeMemory(CoachToolCall call) {
    final fact = CoachToolResultHelpers.stringArg(call, 'fact')?.trim();
    if (fact == null || fact.isEmpty || fact.length > 240) {
      return CoachToolResultHelpers.error(
        call,
        'A concise memory of 240 characters or fewer is required.',
      );
    }
    final pending = PendingCoachAction(
      id: 'memory_${DateTime.now().microsecondsSinceEpoch}',
      type: CoachActionType.saveMemory,
      title: 'Remember this?',
      explanation: fact,
      payload: {'fact': fact},
    );
    return CoachToolResult(
      toolCall: call,
      isError: false,
      promptSummary:
          'A coach-memory proposal is awaiting explicit confirmation.',
      displayLabel: 'Prepared a memory proposal',
      pendingActions: [pending],
    );
  }

  HealthSeries _checkInSeries(
    List<HealthCheckIn> checkIns,
    HealthMetric metric,
    int Function(HealthCheckIn) value,
  ) => HealthSeries(
    id: metric.name,
    label: metric.label,
    metric: metric,
    unit: metric.unit,
    points: checkIns
        .map(
          (item) =>
              HealthDataPoint(date: item.date, value: value(item).toDouble()),
        )
        .toList(),
  );

  static const _safeExperimentCatalog = <String, String>{
    'morning_daylight': 'Spend ten minutes in morning daylight.',
    'gentle_movement': 'Take a ten-minute gentle walk or mobility break.',
    'movement_breaks': 'Take a short movement break every two hours.',
    'sleep_consistency': 'Keep bedtime within the same 30-minute window.',
    'wind_down': 'Use a ten-minute screen-free wind-down before bed.',
    'recovery_pause': 'Choose a quieter recovery period when energy is low.',
    'reflection': 'Write a two-minute reflection on energy and mood.',
  };

  List<double> _valuesForCheckIns(
    List<HealthCheckIn> checkIns,
    Map<DateTime, HealthSummary> summaries,
    HealthMetric metric,
  ) => checkIns
      .map(
        (item) =>
            summaries[DateTime(item.date.year, item.date.month, item.date.day)],
      )
      .whereType<HealthSummary>()
      .map(metric.valueFrom)
      .whereType<double>()
      .toList();

  double _mean(List<double> values) =>
      values.reduce((a, b) => a + b) / values.length;
}
