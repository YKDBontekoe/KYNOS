import 'package:kynos/domain/entities/chat_message.dart';
import 'package:kynos/domain/entities/cloud_data_level.dart';
import 'package:kynos/domain/entities/coach/coach_context.dart';
import 'package:kynos/domain/entities/health_summary.dart';
import 'package:kynos/domain/utils/coach_context_formatter.dart';
import 'package:kynos/domain/utils/health_context_formatter.dart';

/// Builds the user turn for coach chat (system instruction lives on [InferenceChat]).
String buildCoachUserMessage(
  String userMessage,
  List<HealthSummary>? healthContext, {
  CoachContext? coachContext,
  List<ChatMessage>? conversationHistory,
  CloudDataLevel cloudLevel = CloudDataLevel.full,
  bool includePrivateMemory = false,
}) {
  final sections = <String>[];

  final historyBlock = _formatHistoryBlock(conversationHistory);
  if (historyBlock.isNotEmpty) {
    sections.add(historyBlock);
  }

  if (coachContext != null) {
    final block = CoachContextFormatter.formatForPrompt(
      coachContext,
      cloudLevel: cloudLevel,
      includePrivateMemory: includePrivateMemory,
    );
    if (block.isNotEmpty) {
      sections.add('Private wellbeing context:\n$block');
    }
  } else if (healthContext != null && healthContext.isNotEmpty) {
    final lines = HealthContextFormatter.summarizeForPrompt(
      healthContext,
      level: cloudLevel,
    );
    sections.add('Recent wellbeing metrics:\n${lines.join('\n')}');
  }

  sections.add('Person’s question: $userMessage');
  return sections.join('\n\n');
}

String _formatHistoryBlock(List<ChatMessage>? history) {
  if (history == null || history.isEmpty) return '';
  final lines = history
      .where((m) => m.content.trim().isNotEmpty && !m.isStreaming)
      .map(
        (m) => switch (m.role) {
          MessageRole.user => 'Person: ${m.content.trim()}',
          MessageRole.assistant => 'Coach: ${m.content.trim()}',
        },
      )
      .toList();
  if (lines.isEmpty) return '';
  return 'Recent conversation:\n${lines.join('\n')}';
}
