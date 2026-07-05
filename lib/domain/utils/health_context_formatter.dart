import 'package:kynos/domain/entities/cloud_data_level.dart';
import 'package:kynos/domain/entities/health_summary.dart';

/// Formats [HealthSummary] rows for LLM prompts without raw GPS or device IDs.
abstract final class HealthContextFormatter {
  static List<String> summarizeForPrompt(
    List<HealthSummary> summaries, {
    CloudDataLevel level = CloudDataLevel.minimal,
  }) {
    if (summaries.isEmpty) return const [];

    final sorted = List<HealthSummary>.from(summaries)
      ..sort((a, b) => b.date.compareTo(a.date));

    final take = switch (level) {
      CloudDataLevel.minimal => 3,
      CloudDataLevel.standard => 7,
      CloudDataLevel.full => 14,
    };

    return sorted.take(take).map((s) => _formatRow(s, level)).toList();
  }

  static String _formatRow(HealthSummary s, CloudDataLevel level) {
    final date = '${s.date.month}/${s.date.day}';
    final parts = <String>[date];

    if (s.hrvMs != null) parts.add('HRV ${s.hrvMs!.round()}ms');
    if (s.rhrBpm != null) parts.add('RHR ${s.rhrBpm!.round()}');
    if (s.sleepHours != null) {
      parts.add('sleep ${s.sleepHours!.toStringAsFixed(1)}h');
    }
    if (s.runningWorkoutDistanceMeters != null &&
        s.runningWorkoutDistanceMeters! > 0) {
      final km = s.runningWorkoutDistanceMeters! / 1000;
      parts.add('run ${km.toStringAsFixed(1)}km');
    }

    if (level == CloudDataLevel.standard || level == CloudDataLevel.full) {
      if (s.cadenceSpm != null) {
        parts.add('cadence ${s.cadenceSpm!.round()}');
      }
      if (s.runningPowerWatts != null) {
        parts.add('power ${s.runningPowerWatts!.round()}W');
      }
    }

    if (level == CloudDataLevel.full) {
      if (s.steps != null) parts.add('steps ${s.steps}');
      if (s.exerciseMinutes != null) {
        parts.add('exercise ${s.exerciseMinutes!.round()}min');
      }
    }

    return parts.join(', ');
  }
}
