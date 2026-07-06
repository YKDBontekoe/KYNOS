import 'dart:async';

import 'package:kynos/domain/entities/gamification/quest.dart';
import 'package:kynos/features/character/providers/quest_provider.dart';
import 'package:kynos/shared/providers/daily_quests_provider.dart';
import 'package:kynos/shared/providers/gamification_providers.dart';
import 'package:kynos/shared/providers/health_providers.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'measurable_quest_sync_provider.g.dart';

bool _isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

/// Keeps measurable daily quests in sync with health data app-wide.
@Riverpod(keepAlive: true)
class MeasurableQuestSync extends _$MeasurableQuestSync {
  final _logger = Logger();
  Future<void>? _syncInFlight;

  @override
  void build() {
    ref.listen(healthSummaryProvider, (_, _) {
      unawaited(_enqueueSync());
    });
    ref.listen(recentRunsProvider(days: 1, limit: 20), (_, _) {
      unawaited(_enqueueSync());
    });
    unawaited(_enqueueSync());
  }

  Future<void> _enqueueSync() {
    final inFlight = _syncInFlight;
    if (inFlight != null) return inFlight;

    late final Future<void> sync;
    sync = _syncMeasurableQuests().whenComplete(() {
      if (identical(_syncInFlight, sync)) {
        _syncInFlight = null;
      }
    });
    _syncInFlight = sync;
    return sync;
  }

  Future<void> _syncMeasurableQuests() async {
    try {
      final quests = await ref.read(dailyQuestsProvider.future);
      if (quests.isEmpty) return;

      final evaluator = ref.read(evaluateQuestProgressUseCaseProvider);
      final summary = ref.read(healthSummaryProvider).value;
      final runs =
          await ref.read(recentRunsProvider(days: 1, limit: 20).future);
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
    } on Object catch (error, stackTrace) {
      _logger.w(
        'Measurable quest sync failed',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }
}
