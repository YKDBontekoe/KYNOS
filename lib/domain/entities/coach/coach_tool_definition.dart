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
      name: 'get_recent_runs',
      purpose: 'List recent runs (pace/distance) beyond the summary above',
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
      name: 'get_health_trend',
      purpose: 'Trend for one metric over N days',
      argsHint: 'metric hrv|rhr|sleep|steps, days 3-60',
      actionLabel: 'Analyzing your health trend',
    ),
    CoachToolDefinition(
      name: 'get_training_load',
      purpose: 'ACWR, weekly goal progress, adjustment hints',
      argsHint: 'none',
      actionLabel: 'Reviewing your training load',
    ),
    CoachToolDefinition(
      name: 'get_character_progress',
      purpose: 'Level, class, weakest stat, active quests',
      argsHint: 'none',
      actionLabel: 'Checking your character progress',
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
    return 'Tools you may call for more data or math:\n$lines\n'
        'To call one, reply with ONLY: TOOL_CALL: {"name":"<tool>","arguments":{...}}\n'
        'Then wait for the result before calling another tool or answering. '
        'Never mention tools or TOOL_CALL in your final answer to the athlete.';
  }
}
