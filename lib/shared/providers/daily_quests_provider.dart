import 'package:kynos/domain/entities/gamification/quest.dart';
import 'package:kynos/domain/utils/readiness_score.dart';
import 'package:kynos/shared/providers/gamification_providers.dart';
import 'package:kynos/shared/providers/health_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'daily_quests_provider.g.dart';

Future<List<Quest>>? _dailyQuestsInFlight;

/// Returns today's active quests, generating new ones via AI if none exist.
///
/// Lives in shared so dashboard and character tabs can both consume it
/// without cross-feature provider imports.
@Riverpod(keepAlive: true)
Future<List<Quest>> dailyQuests(Ref ref) async {
  if (_dailyQuestsInFlight != null) {
    return _dailyQuestsInFlight!;
  }

  final future = _loadOrGenerateDailyQuests(ref);
  _dailyQuestsInFlight = future;
  try {
    return await future;
  } finally {
    if (identical(_dailyQuestsInFlight, future)) {
      _dailyQuestsInFlight = null;
    }
  }
}

Future<List<Quest>> _loadOrGenerateDailyQuests(Ref ref) async {
  final repo = ref.read(characterRepositoryProvider);

  final loadResult = await repo.loadTodayQuests();
  if (loadResult.quests.isNotEmpty) return loadResult.quests;

  final characterResult = await repo.loadCharacter();
  final character = characterResult.character;
  if (character == null) return const [];

  final summary = await ref.watch(healthSummaryProvider.future);
  final readiness = readinessScoreOrDefault(summary);

  final useCase = ref.read(generateDailyQuestsUseCaseProvider);
  final result = await useCase(
    character: character,
    readinessScore: readiness,
  );

  if (result.failure != null) {
    throw result.failure!;
  }

  if (result.quests.isNotEmpty) {
    await repo.saveQuests(result.quests);
  }

  return result.quests;
}
