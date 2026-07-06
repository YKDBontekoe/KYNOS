import 'dart:async';

import 'package:kynos/domain/entities/gamification/quest.dart';
import 'package:kynos/features/character/providers/quest_provider.dart';
import 'package:kynos/shared/providers/daily_quests_provider.dart';
import 'package:kynos/shared/providers/gamification_providers.dart';
import 'package:kynos/shared/providers/health_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'measurable_quest_sync_provider.g.dart';

bool _isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

/// Keeps measurable daily quests in sync with health data app-wide.
@Riverpod(keepAlive: true)
class MeasurableQuestSync extends _$MeasurableQuestSync {
  @override
  void build() {
    ref.listen(healthSummaryProvider, (_, _) {
      unawaited(_syncMeasurableQuests());
    });
    ref.listen(recentRunsProvider(days: 1, limit: 20), (_, _) {
      unawaited(_syncMeasurableQuests());
    });
    unawaited(_syncMeasurableQuests());
  }

  Future<void> _syncMeasurableQuests() async {
    final quests = await ref.read(dailyQuestsProvider.future);
    if (quests.isEmpty) return;

    final evaluator = ref.read(evaluateQuestProgressUseCaseProvider);
    final summary = ref.read(healthSummaryProvider).value;
    final runs = await ref.read(recentRunsProvider(days: 1, limit: 20).future);
    final today = DateTime.now();
    final todayRuns = runs.where((r) => _isSameDay(r.start, today)).toList();

    for (final quest in quests) {
      if (quest.status != QuestStatus.active) continue;
      if (quest.measurableObjective == null) continue;
      if (!evaluator.isComplete(
        quest: quest,
        summary: summary,
        todayRuns: todayRuns,
      )) {
        continue;
      }
      await ref.read(questProvider.notifier).completeQuest(quest.id);
    }
  }
}
