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
    final completedQuest = current.firstWhere((q) => q.id == questId);
    final updated = current.map((q) {
      if (q.id != questId) return q;
      return q.copyWith(
        status: QuestStatus.completed,
        completedAt: DateTime.now(),
      );
    }).toList();

    final repo = ref.read(characterRepositoryProvider);
    final charResult = await repo.loadCharacter();
    if (charResult.character != null) {
      final updatedChar = charResult.character!.withXpGain(
        completedQuest.xpReward,
        statDeltas: completedQuest.statRewards,
      );
      final saveCharacterFailure = await repo.saveCharacter(updatedChar);
      if (saveCharacterFailure != null) {
        state = AsyncError(saveCharacterFailure, StackTrace.current);
        return;
      }
      ref.invalidate(runnerCharacterProvider);
    }

    final saveQuestsFailure = await repo.saveQuests(updated);
    if (saveQuestsFailure != null) {
      state = AsyncError(saveQuestsFailure, StackTrace.current);
      return;
    }
    state = AsyncData(updated);
  }
}
