import 'package:kynos/domain/entities/gamification/quest.dart';
import 'package:kynos/features/character/providers/character_provider.dart';
import 'package:kynos/shared/providers/daily_quests_provider.dart';
import 'package:kynos/shared/providers/gamification_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'quest_provider.g.dart';

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

    final completedQuest = updated.firstWhere((q) => q.id == questId);
    final charRepo = ref.read(characterRepositoryProvider);
    final charResult = await charRepo.loadCharacter();
    if (charResult.character != null) {
      final updatedChar = charResult.character!.withXpGain(
        completedQuest.xpReward,
        statDeltas: completedQuest.statRewards,
      );
      await charRepo.saveCharacter(updatedChar);
      ref.invalidate(runnerCharacterProvider);
    }
  }
}
