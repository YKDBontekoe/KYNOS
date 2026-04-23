import 'package:kynos/domain/entities/gamification/quest.dart';
import 'package:kynos/domain/entities/health_summary.dart';
import 'package:kynos/features/character/providers/character_provider.dart';
import 'package:kynos/shared/providers/health_providers.dart';
import 'package:kynos/shared/providers/gamification_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'quest_provider.g.dart';

/// Returns today's active quests, generating new ones via AI if none exist.
@Riverpod(keepAlive: true)
Future<List<Quest>> dailyQuests(DailyQuestsRef ref) async {
  final repo = ref.read(characterRepositoryProvider);

  final loadResult = await repo.loadTodayQuests();
  if (loadResult.quests.isNotEmpty) return loadResult.quests;

  final character = await ref.watch(runnerCharacterProvider.future);
  if (character == null) return const [];

  final summary = await ref.watch(healthSummaryProvider.future);
  final readiness = _computeReadiness(summary);

  final useCase = ref.read(generateDailyQuestsUseCaseProvider);
  final result = await useCase(
    character: character,
    readinessScore: readiness,
  );

  if (result.quests.isNotEmpty) {
    await repo.saveQuests(result.quests);
  }

  return result.quests;
}

/// Notifier that allows quest status mutations (complete / expire).
@Riverpod(keepAlive: true)
class QuestNotifier extends _$QuestNotifier {
  @override
  Future<List<Quest>> build() => ref.watch(dailyQuestsProvider.future);

  Future<void> completeQuest(String questId) async {
    final current = await future;
    final updated = current.map((q) {
      if (q.id != questId) return q;
      return q.copyWith(
        status: QuestStatus.completed,
        completedAt: DateTime.now(),
      );
    }).toList();

    final repo = ref.read(characterRepositoryProvider);
    await repo.saveQuests(updated);
    state = AsyncData(updated);

    // Apply XP reward to character
    final completedQuest =
        updated.firstWhere((q) => q.id == questId);
    final charRepo = ref.read(characterRepositoryProvider);
    final charResult = await charRepo.loadCharacter();
    if (charResult.character != null) {
      final updated = charResult.character!.withXpGain(
        completedQuest.xpReward,
        statDeltas: completedQuest.statRewards,
      );
      await charRepo.saveCharacter(updated);
      ref.invalidate(runnerCharacterProvider);
    }
  }
}

double _computeReadiness(HealthSummary? summary) {
  if (summary == null) return 60;
  final hrvScore = ((summary.hrvMs ?? 40).clamp(20, 110) - 20) / 90;
  final rhrScore =
      1 - (((summary.rhrBpm ?? 65).clamp(45, 90) - 45) / 45);
  final sleepScore = ((summary.sleepHours ?? 7).clamp(4, 9) - 4) / 5;
  final spo2Score =
      ((summary.bloodOxygenPercent ?? 97).clamp(90, 100) - 90) / 10;
  return ((hrvScore * 0.35 +
              rhrScore * 0.25 +
              sleepScore * 0.25 +
              spo2Score * 0.15) *
          100)
      .clamp(0, 100);
}
