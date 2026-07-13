import 'package:kynos/domain/entities/coach/coach_context.dart';
import 'package:kynos/domain/entities/coach/coach_context_preferences.dart';
import 'package:kynos/domain/entities/coach/coach_tool_call.dart';
import 'package:kynos/domain/repositories/health_repository.dart';
import 'package:kynos/domain/usecases/coach/coach_tool_context_queries.dart';
import 'package:kynos/domain/usecases/coach/coach_tool_health_queries.dart';

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
      : _healthQueries = CoachToolHealthQueries(healthRepository: healthRepository);

  final CoachToolHealthQueries _healthQueries;
  final _contextQueries = const CoachToolContextQueries();

  Future<CoachToolResult> call({
    required CoachToolCall toolCall,
    required CoachContext context,
    required CoachContextPreferences preferences,
  }) async {
    try {
      switch (toolCall.name) {
        case 'get_recent_runs':
          return await _healthQueries.getRecentRuns(toolCall, preferences);
        case 'get_run_detail':
          return await _healthQueries.getRunDetail(toolCall, preferences);
        case 'get_health_trend':
          return await _healthQueries.getHealthTrend(toolCall, preferences);
        case 'get_training_load':
          return _contextQueries.getTrainingLoad(toolCall, context, preferences);
        case 'get_character_progress':
          return _contextQueries.getCharacterProgress(toolCall, context, preferences);
        case 'get_personal_bests':
          return _contextQueries.getPersonalBests(toolCall, context, preferences);
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
