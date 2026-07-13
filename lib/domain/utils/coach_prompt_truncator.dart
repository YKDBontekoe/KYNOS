import 'package:kynos/domain/utils/gemma_inference_limits.dart';

/// Marker for the athlete question block — must match [coach_prompt_builder].
const coachQuestionMarker = 'Person’s question:';

/// Truncates a coach user prompt while always preserving the question block.
String truncateCoachPrompt(
  String prompt, {
  int maxChars = GemmaInferenceLimits.maxPromptCharacters,
}) {
  if (prompt.length <= maxChars) return prompt;

  final questionIndex = prompt.lastIndexOf(coachQuestionMarker);
  if (questionIndex < 0) {
    return prompt.substring(0, maxChars);
  }

  final questionPart = prompt.substring(questionIndex);
  final contextBudget = maxChars - questionPart.length - 2;
  if (contextBudget <= 0) {
    return questionPart.substring(0, maxChars);
  }

  final contextPart = prompt.substring(0, questionIndex).trimRight();
  if (contextPart.length <= contextBudget) {
    return '$contextPart\n\n$questionPart';
  }

  final trimmedContext = contextPart.substring(0, contextBudget).trimRight();
  return '$trimmedContext\n\n$questionPart';
}

/// Heuristic for responses cut off by the on-device output token budget.
bool coachResponseLooksTruncated(
  String text, {
  required int maxOutputTokens,
}) {
  final trimmed = text.trim();
  if (trimmed.isEmpty) return false;

  const terminators = {'.', '!', '?', ')', ']', '"', '»'};
  if (terminators.any(trimmed.endsWith)) return false;
  if (trimmed.endsWith('...') || trimmed.endsWith('…')) return false;

  // Roughly 3–4 chars per token for English coach replies.
  final charThreshold = (maxOutputTokens * 3 * 0.75).round();
  return trimmed.length >= charThreshold;
}
