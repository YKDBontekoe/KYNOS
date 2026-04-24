// TODO (AI): Extract AI coach + model repository access into a shared provider
// (e.g. shared/providers/ai_repository_provider.dart) so that feature providers
// depend only on domain interfaces and never import from infrastructure/ directly.
import 'package:kynos/features/dashboard/providers/health_provider.dart';
import 'package:kynos/infrastructure/ai/ai_infrastructure_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'ai_insight_provider.g.dart';

/// Generates a single coaching sentence from today's health data using the
/// on-device model. Returns null silently when the model is not installed
/// or when insufficient health data is available.
///
/// Kept alive for the app session — only regenerates when health data changes.
@Riverpod(keepAlive: true)
Future<String?> aiDailyInsight(AiDailyInsightRef ref) async {
  final summary = await ref.watch(healthSummaryProvider.future);
  if (summary == null) return null;

  final modelRepo = ref.read(aiModelRepositoryProvider);
  try {
    await modelRepo.initialize();
  } catch (_) {
    return null;
  }
  if (!modelRepo.hasActiveModel) return null;

  final parts = <String>[];
  if (summary.hrvMs != null) parts.add('HRV ${summary.hrvMs!.round()} ms');
  if (summary.rhrBpm != null) parts.add('RHR ${summary.rhrBpm!.round()} bpm');
  if (summary.sleepHours != null) {
    parts.add('sleep ${summary.sleepHours!.toStringAsFixed(1)} h');
  }
  if (summary.bloodOxygenPercent != null) {
    parts.add('SpO2 ${summary.bloodOxygenPercent!.toStringAsFixed(1)}%');
  }
  if (summary.activeCalories != null) {
    parts.add('active ${summary.activeCalories!.round()} kcal');
  }
  if (parts.isEmpty) return null;

  final prompt =
      'Athlete metrics: ${parts.join(', ')}. '
      'Respond in one sentence, maximum 12 words, no greeting, no filler: '
      'what does this mean for training today?';

  try {
    final coach = ref.read(aiCoachRepositoryProvider);
    await coach.resetSession();
    final buffer = StringBuffer();
    await for (final chunk in coach.chat(userMessage: prompt)) {
      buffer.write(chunk);
    }
    final result = buffer
        .toString()
        .trim()
        .replaceAll(RegExp(r'^["""]+|["""]+$'), '')
        .trim();
    return result.isEmpty ? null : result;
  } catch (_) {
    return null;
  }
}
