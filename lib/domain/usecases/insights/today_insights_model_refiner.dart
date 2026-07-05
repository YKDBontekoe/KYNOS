import 'dart:async';

import 'package:kynos/domain/entities/health_summary.dart';
import 'package:kynos/domain/entities/insights/today_insights.dart';
import 'package:kynos/domain/repositories/ai_coach_repository.dart';
import 'package:kynos/domain/repositories/ai_model_repository.dart';

/// Refines baseline today insights using the on-device model.
class TodayInsightsModelRefiner {
  const TodayInsightsModelRefiner({
    required AiCoachRepository aiCoachRepository,
    required AiModelRepository aiModelRepository,
  }) : _aiCoachRepository = aiCoachRepository,
       _aiModelRepository = aiModelRepository;

  final AiCoachRepository _aiCoachRepository;
  final AiModelRepository _aiModelRepository;

  Future<TodayInsights?> refine({
    required TodayInsights baseline,
    required HealthSummary today,
    required HealthSummary? yesterday,
    required List<HealthSummary> history,
  }) async {
    try {
      await _aiModelRepository.initialize();
      if (!_aiModelRepository.hasActiveModel) return null;

      final contextLines = <String>[
        'Today HRV: ${today.hrvMs?.toStringAsFixed(1) ?? 'na'}',
        'Today RHR: ${today.rhrBpm?.toStringAsFixed(1) ?? 'na'}',
        'Today sleep: ${today.sleepHours?.toStringAsFixed(1) ?? 'na'}',
        'Today SpO2: ${today.bloodOxygenPercent?.toStringAsFixed(1) ?? 'na'}',
        'Yesterday HRV: ${yesterday?.hrvMs?.toStringAsFixed(1) ?? 'na'}',
        '14d records: ${history.length}',
      ];

      final prompt = StringBuffer()
        ..writeln('Task: refine concise daily training insight text.')
        ..writeln(
          'Model size is small: avoid complex reasoning and keep outputs short.',
        )
        ..writeln(
          'Use only provided context and baseline insight. Do not invent data.',
        )
        ..writeln('Return EXACTLY these keys, one per line:')
        ..writeln('READINESS_BRIEF: ...')
        ..writeln('ACTION_NOW: ...')
        ..writeln('ACTION_TONIGHT: ...')
        ..writeln('CHANGED: item1 | item2 | item3')
        ..writeln('RISKS: item1 | item2 | item3')
        ..writeln('')
        ..writeln('Context:')
        ..writeln(contextLines.join('\n'))
        ..writeln('')
        ..writeln('Baseline:')
        ..writeln('READINESS_BRIEF: ${baseline.readinessBrief}')
        ..writeln('ACTION_NOW: ${baseline.actionNow}')
        ..writeln('ACTION_TONIGHT: ${baseline.actionTonight}')
        ..writeln('CHANGED: ${baseline.whatChanged.join(' | ')}')
        ..writeln('RISKS: ${baseline.riskFlags.join(' | ')}');

      await _aiCoachRepository.resetSession();
      final buffer = StringBuffer();
      await for (final chunk in _aiCoachRepository
          .chat(userMessage: prompt.toString())
          .timeout(const Duration(seconds: 30))) {
        buffer.write(chunk);
      }

      final parsed = parseInsightModelText(buffer.toString());
      if (parsed == null) return null;

      return baseline.copyWith(
        readinessBrief: parsed.readinessBrief,
        actionNow: parsed.actionNow,
        actionTonight: parsed.actionTonight,
        whatChanged: parsed.changed,
        riskFlags: parsed.risks,
      );
    } catch (_) {
      return null;
    }
  }
}

/// Parsed key-value output from insight model refinement prompts.
({
  String readinessBrief,
  String actionNow,
  String actionTonight,
  List<String> changed,
  List<String> risks,
})?
parseInsightModelText(String raw) {
  String? take(String key) {
    final match = RegExp('^$key\\s*:(.*)', multiLine: true).firstMatch(raw);
    return match?.group(1)?.trim();
  }

  List<String> splitList(String? value) {
    if (value == null || value.isEmpty) return const [];
    return value
        .split('|')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .take(3)
        .toList();
  }

  final readinessBrief = take('READINESS_BRIEF');
  final actionNow = take('ACTION_NOW');
  final actionTonight = take('ACTION_TONIGHT');

  if (readinessBrief == null || actionNow == null || actionTonight == null) {
    return null;
  }

  return (
    readinessBrief: readinessBrief,
    actionNow: actionNow,
    actionTonight: actionTonight,
    changed: splitList(take('CHANGED')),
    risks: splitList(take('RISKS')),
  );
}
