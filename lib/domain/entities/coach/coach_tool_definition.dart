/// Describes one tool the coach agent may call for on-demand data or math.
class CoachToolDefinition {
  const CoachToolDefinition({
    required this.name,
    required this.purpose,
    required this.argsHint,
    required this.actionLabel,
  });

  /// Stable identifier the model must echo back in a `TOOL_CALL` directive.
  final String name;

  /// One-line description shown to the model in the tool catalog.
  final String purpose;

  /// Compact argument hint shown to the model, e.g. `limit (1-10)`.
  final String argsHint;

  /// Present-tense label shown in the chat UI while/after the tool runs,
  /// e.g. "Checking your recent runs".
  final String actionLabel;
}

/// Static catalog of agentic coach tools plus the system-prompt block that
/// teaches the model how to call them.
///
/// Kept intentionally compact — every extra token here competes with the
/// on-device model's tiny prompt budget (see `GemmaInferenceLimits`).
abstract final class CoachAgentToolCatalog {
  static const List<CoachToolDefinition> definitions = [
    CoachToolDefinition(
      name: 'get_daily_health_brief',
      purpose: 'Read today’s deterministic wellbeing brief and evidence',
      argsHint: 'none',
      actionLabel: 'Reviewing today’s health brief',
    ),
    CoachToolDefinition(
      name: 'get_health_trend',
      purpose: 'Validated trend chart for one health metric',
      argsHint:
          'metric hrv|rhr|heart_rate|respiratory_rate|blood_oxygen|sleep|steps|distance|exercise|active_energy, days 7-90',
      actionLabel: 'Analyzing a health trend',
    ),
    CoachToolDefinition(
      name: 'compare_health_periods',
      purpose: 'Compare adjacent periods using local medians and a table',
      argsHint: 'metric, days 7-30',
      actionLabel: 'Comparing health periods',
    ),
    CoachToolDefinition(
      name: 'compare_high_low_days',
      purpose: 'Compare measured signals on high- and low-energy check-in days',
      argsHint: 'none',
      actionLabel: 'Comparing how different days felt',
    ),
    CoachToolDefinition(
      name: 'find_metric_association',
      purpose:
          'Spearman association for two metrics; never establishes causation',
      argsHint: 'x_metric, y_metric, days 14-90',
      actionLabel: 'Checking a possible association',
    ),
    CoachToolDefinition(
      name: 'build_health_timeline',
      purpose: 'Timeline of measured sleep and movement events',
      argsHint: 'days 7-60',
      actionLabel: 'Building your health timeline',
    ),
    CoachToolDefinition(
      name: 'get_check_in_history',
      purpose: 'Self-reported energy, mood, and stress trend',
      argsHint: 'days 7-60',
      actionLabel: 'Reviewing how you have felt',
    ),
    CoachToolDefinition(
      name: 'get_experiment_status',
      purpose: 'Status of confirmed local wellbeing experiments',
      argsHint: 'none',
      actionLabel: 'Reviewing your experiments',
    ),
    CoachToolDefinition(
      name: 'propose_wellbeing_experiment',
      purpose: 'Propose one low-risk 3-14 day experiment; user must confirm',
      argsHint:
          'title, action_id (morning_daylight|gentle_movement|movement_breaks|sleep_consistency|wind_down|recovery_pause|reflection), hypothesis, duration_days',
      actionLabel: 'Preparing an experiment',
    ),
    CoachToolDefinition(
      name: 'propose_coach_memory',
      purpose: 'Propose a concise local memory; user must confirm',
      argsHint: 'fact',
      actionLabel: 'Preparing a memory',
    ),
    CoachToolDefinition(
      name: 'get_recent_runs',
      purpose: 'List recent runs when activity detail is directly relevant',
      argsHint: 'limit 1-10, days 1-90',
      actionLabel: 'Checking your recent runs',
    ),
    CoachToolDefinition(
      name: 'get_run_detail',
      purpose: 'Per-kilometer pace splits for one run',
      argsHint: 'run_id',
      actionLabel: "Pulling up that run's splits",
    ),
    CoachToolDefinition(
      name: 'get_training_load',
      purpose: 'ACWR, weekly goal progress, adjustment hints',
      argsHint: 'none',
      actionLabel: 'Reviewing your training load',
    ),
    CoachToolDefinition(
      name: 'get_personal_bests',
      purpose: 'Recent personal-best callouts',
      argsHint: 'none',
      actionLabel: 'Scanning for personal bests',
    ),
    CoachToolDefinition(
      name: 'compute_pace_plan',
      purpose: 'Even-split pace plan for a target distance/time',
      argsHint: 'distance_km, target_time_minutes',
      actionLabel: 'Calculating a pace plan',
    ),
  ];

  static CoachToolDefinition? byName(String name) {
    for (final def in definitions) {
      if (def.name == name) return def;
    }
    return null;
  }

  static String actionLabelFor(String name) =>
      byName(name)?.actionLabel ?? 'Using $name';

  /// Instruction block appended to the coach system prompt.
  static String get systemPromptBlock {
    final lines = definitions
        .map((d) => '- ${d.name}(${d.argsHint}): ${d.purpose}')
        .join('\n');
    return 'You are a private daily wellbeing coach for generally healthy adults. '
        'Interpret patterns without diagnosing. Distinguish measured data, self-report, '
        'and inference. Recommend at most one proportionate low-risk action. '
        'Never claim that an association proves causation.\n\n'
        'Tools you may call for more data, deterministic analysis, or native visuals:\n$lines\n'
        'To call one, reply with ONLY: TOOL_CALL: {"name":"<tool>","arguments":{...}}\n'
        'Then wait for the result before calling another tool or answering. '
        'Never mention tools or TOOL_CALL in your final answer to the person.';
  }
}
