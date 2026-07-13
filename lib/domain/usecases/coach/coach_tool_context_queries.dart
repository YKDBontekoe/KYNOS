import 'package:kynos/domain/entities/coach/coach_context.dart';
import 'package:kynos/domain/entities/coach/coach_context_preferences.dart';
import 'package:kynos/domain/entities/coach/coach_data_source.dart';
import 'package:kynos/domain/entities/coach/coach_tool_call.dart';
import 'package:kynos/domain/utils/coach_tool_result_helpers.dart';
import 'package:kynos/domain/utils/pace_format.dart';
import 'package:kynos/domain/utils/personal_bests.dart';

/// Coach agent tools that answer from the already-fetched [CoachContext] or
/// pure math — no repository access required.
class CoachToolContextQueries {
  const CoachToolContextQueries();

  CoachToolResult getTrainingLoad(
    CoachToolCall call,
    CoachContext context,
    CoachContextPreferences prefs,
  ) {
    if (!prefs.isEnabled(CoachDataSource.readinessAcwr) &&
        !prefs.isEnabled(CoachDataSource.weeklyMomentum)) {
      return CoachToolResultHelpers.disabled(call, CoachDataSource.readinessAcwr);
    }

    final parts = <String>[];
    if (context.acwr != null) {
      parts.add(
        'ACWR ${context.acwr!.toStringAsFixed(2)} (${context.acwrRiskLabel ?? 'no label'})',
      );
    }
    final momentum = context.weeklyMomentum;
    if (momentum != null) {
      parts.add(
        '${momentum.thisWeekDistanceKm.toStringAsFixed(1)}/'
        '${momentum.distanceGoalKm.toStringAsFixed(0)}km this week',
      );
    }
    final hints = context.trainingInsights?.adjustmentHints ?? const [];
    if (hints.isNotEmpty) {
      parts.add('Hints: ${hints.take(2).join('; ')}');
    }

    if (parts.isEmpty) {
      return CoachToolResult(
        call: call,
        isError: false,
        promptSummary: 'Not enough data yet to assess training load.',
        displayLabel: 'Training load unavailable',
      );
    }
    return CoachToolResult(
      call: call,
      isError: false,
      promptSummary: parts.join('. '),
      displayLabel: 'Training load reviewed',
    );
  }

  CoachToolResult getCharacterProgress(
    CoachToolCall call,
    CoachContext context,
    CoachContextPreferences prefs,
  ) {
    if (!prefs.isEnabled(CoachDataSource.characterQuests)) {
      return CoachToolResultHelpers.disabled(call, CoachDataSource.characterQuests);
    }

    final character = context.character;
    if (character == null) {
      return CoachToolResult(
        call: call,
        isError: false,
        promptSummary: 'No character data yet.',
        displayLabel: 'No character yet',
      );
    }

    final quests = context.activeQuests.map((q) => q.title).join(', ');
    final summary = 'Lv${character.level} ${character.characterClass.name}, '
        'weakest stat ${character.stats.weakest.fullName}.'
        '${quests.isEmpty ? '' : ' Active quests: $quests.'}';
    return CoachToolResult(
      call: call,
      isError: false,
      promptSummary: summary,
      displayLabel: 'Character progress checked',
    );
  }

  CoachToolResult getPersonalBests(
    CoachToolCall call,
    CoachContext context,
    CoachContextPreferences prefs,
  ) {
    if (!prefs.isEnabled(CoachDataSource.healthMetrics)) {
      return CoachToolResultHelpers.disabled(call, CoachDataSource.healthMetrics);
    }

    final today = context.healthHistory.isNotEmpty ? context.healthHistory.first : null;
    final callouts = findPersonalBestCallouts(context.healthHistory, today);
    if (callouts.isEmpty) {
      return CoachToolResult(
        call: call,
        isError: false,
        promptSummary: 'No new personal bests recently.',
        displayLabel: 'No new PBs',
      );
    }
    return CoachToolResult(
      call: call,
      isError: false,
      promptSummary: callouts.join('; '),
      displayLabel: '${callouts.length} PB${callouts.length == 1 ? '' : 's'} found',
    );
  }

  CoachToolResult computePacePlan(CoachToolCall call) {
    final distanceKm =
        CoachToolResultHelpers.doubleArg(call, 'distance_km', fallback: 5.0, min: 0.5, max: 200);
    final targetMinutes = CoachToolResultHelpers.rawDoubleArg(call, 'target_time_minutes');
    if (targetMinutes == null || targetMinutes <= 0) {
      return CoachToolResultHelpers.error(
        call,
        'Provide target_time_minutes to compute a pace plan.',
      );
    }

    final secondsPerKm = (targetMinutes * 60) / distanceKm;
    final pace = formatPacePerKm(secondsPerKm);
    return CoachToolResult(
      call: call,
      isError: false,
      promptSummary:
          'For ${distanceKm.toStringAsFixed(1)}km in ${targetMinutes.toStringAsFixed(0)} min, '
          'hold an even $pace pace throughout.',
      displayLabel: 'Pace plan: $pace',
    );
  }
}
