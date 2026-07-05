import 'package:kynos/domain/entities/health_summary.dart';
import 'package:kynos/domain/utils/health_context_formatter.dart';

/// Builds the user turn for coach chat (system instruction lives on [InferenceChat]).
String buildCoachUserMessage(
  String userMessage,
  List<HealthSummary>? healthContext,
) {
  if (healthContext == null || healthContext.isEmpty) return userMessage;
  final lines = HealthContextFormatter.summarizeForPrompt(healthContext);
  return 'Recent athlete metrics:\n${lines.join('\n')}\n\n'
      'Athlete question: $userMessage';
}
