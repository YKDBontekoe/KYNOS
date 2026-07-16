import 'package:kynos/domain/entities/coach/coach_context.dart';
import 'package:kynos/domain/entities/coach/coach_context_preferences.dart';
import 'package:kynos/domain/entities/coach/coach_tool_call.dart';
import 'package:kynos/domain/repositories/health_repository.dart';
import 'package:kynos/domain/usecases/coach/coach_tool_context_queries.dart';
import 'package:kynos/domain/usecases/coach/coach_tool_health_queries.dart';
import 'package:kynos/domain/usecases/coach/coach_tool_wellbeing_queries.dart';

/// Executes agentic coach tool calls.
///
/// Every tool is gated by the same [CoachDataSource] permissions used to
/// build the static coach context, so tool calling can never surface more
/// than the athlete has already consented to share (privacy-first, per
/// AGENTS.md §11). Tool implementations live in [CoachToolHealthQueries]
/// (repository-backed lookups) and [CoachToolContextQueries] (context-only
/// and pure-math tools); this class just dispatches by tool name.
class ExecuteCoachToolUseCase {
  ExecuteCoachToolUseCase({required HealthRepository healthRepository})
    : _healthQueries = CoachToolHealthQueries(
        healthRepository: healthRepository,
      );

  final CoachToolHealthQueries _healthQueries;
  final _contextQueries = const CoachToolContextQueries();
  final _wellbeingQueries = const CoachToolWellbeingQueries();

  Future<CoachToolResult> call({
    required CoachToolCall toolCall,
    required CoachContext context,
    required CoachContextPreferences preferences,
  }) async {
    try {
      switch (toolCall.name) {
        case 'get_daily_health_brief':
          return _wellbeingQueries.getDailyHealthBrief(
            toolCall,
            context,
            preferences,
          );
        case 'get_recent_runs':
          return await _healthQueries.getRecentRuns(toolCall, preferences);
        case 'get_run_detail':
          return await _healthQueries.getRunDetail(toolCall, preferences);
        case 'get_health_trend':
          return await _healthQueries.getHealthTrend(toolCall, preferences);
        case 'compare_health_periods':
          return await _healthQueries.compareHealthPeriods(
            toolCall,
            preferences,
          );
        case 'compare_high_low_days':
          return _wellbeingQueries.compareHighLowDays(
            toolCall,
            context,
            preferences,
          );
        case 'find_metric_association':
          return await _healthQueries.findMetricAssociation(
            toolCall,
            preferences,
          );
        case 'build_health_timeline':
          return await _healthQueries.buildHealthTimeline(
            toolCall,
            preferences,
          );
        case 'get_check_in_history':
          return _wellbeingQueries.getCheckInHistory(
            toolCall,
            context,
            preferences,
          );
        case 'get_experiment_status':
          return _wellbeingQueries.getExperimentStatus(
            toolCall,
            context,
            preferences,
          );
        case 'propose_wellbeing_experiment':
          return _wellbeingQueries.proposeExperiment(toolCall);
        case 'propose_coach_memory':
          return _wellbeingQueries.proposeMemory(toolCall);
        case 'get_training_load':
          return _contextQueries.getTrainingLoad(
            toolCall,
            context,
            preferences,
          );
        case 'get_personal_bests':
          return _contextQueries.getPersonalBests(
            toolCall,
            context,
            preferences,
          );
        case 'compute_pace_plan':
          return _contextQueries.computePacePlan(toolCall);
        default:
          return CoachToolResult(
            toolCall: toolCall,
            isError: true,
            promptSummary: 'Unknown tool "${toolCall.name}".',
            displayLabel: 'Tool error',
          );
      }
    } on Object {
      return CoachToolResult(
        toolCall: toolCall,
        isError: true,
        promptSummary: 'That tool could not complete right now.',
        displayLabel: 'Tool error',
      );
    }
  }
}
