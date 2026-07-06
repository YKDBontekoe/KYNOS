import 'package:kynos/domain/entities/coach/coach_backend_mode.dart';
import 'package:kynos/domain/entities/coach/coach_context.dart';
import 'package:kynos/domain/entities/coach/coach_context_preferences.dart';
import 'package:kynos/domain/entities/coach/coach_data_source.dart';
import 'package:kynos/domain/entities/coach/coach_data_source_snapshot.dart';

/// Builds UI metadata for coach context sources.
class DescribeCoachContextUseCase {
  const DescribeCoachContextUseCase();

  List<CoachDataSourceSnapshot> call({
    required CoachContext context,
    required CoachContextPreferences preferences,
    required CoachBackendMode backendMode,
    required bool cloudConfigured,
  }) {
    final willUseCloud = backendMode == CoachBackendMode.cloud ||
        (backendMode == CoachBackendMode.auto && cloudConfigured);

    return CoachDataSource.all.map((source) {
      final enabled = preferences.isEnabled(source);
      return CoachDataSourceSnapshot(
        source: source,
        label: source.label,
        preview: _previewFor(source, context),
        isEnabled: enabled,
        willSendToCloud: enabled && willUseCloud,
      );
    }).toList();
  }

  String _previewFor(CoachDataSource source, CoachContext context) {
    return switch (source) {
      CoachDataSource.readinessAcwr =>
        'Score ${context.readinessScore.round()}'
            '${context.acwr != null ? ' · ACWR ${context.acwr!.toStringAsFixed(2)}' : ''}',
      CoachDataSource.healthMetrics =>
        context.healthHistory.isEmpty
            ? 'No health data'
            : '${context.healthHistory.length} days of metrics',
      CoachDataSource.recentRuns => _runsPreview(context),
      CoachDataSource.weeklyMomentum => context.weeklyMomentum == null
          ? 'No weekly data'
          : '${context.weeklyMomentum!.thisWeekDistanceKm.toStringAsFixed(1)} km this week',
      CoachDataSource.todayInsights => context.todayInsights == null
          ? 'No today insights'
          : context.todayInsights!.readinessBrief,
      CoachDataSource.trainingInsights => context.trainingInsights == null
          ? 'No training insights'
          : context.trainingInsights!.sessionIntent,
      CoachDataSource.characterQuests => context.character == null
          ? 'No character data'
          : '${context.character!.characterClass.name} Lv${context.character!.level}'
              '${context.activeQuests.isNotEmpty ? ' · ${context.activeQuests.length} quests' : ''}',
      CoachDataSource.gaitBiomechanics => context.isGaitCalibrated
          ? 'Gait model calibrated'
          : 'Gait model not calibrated',
      CoachDataSource.postRunDebrief => context.postRunDebriefSummary == null
          ? 'No recent debrief'
          : context.postRunDebriefSummary!,
    };
  }

  String _runsPreview(CoachContext context) {
    if (context.recentRuns.isEmpty) return 'No recent runs';
    final latest = context.recentRuns.first;
    final date =
        '${latest.start.month}/${latest.start.day}';
    final km = (latest.distanceMeters ?? 0) / 1000;
    return '${context.recentRuns.length} runs · last ${km.toStringAsFixed(1)} km on $date';
  }
}
