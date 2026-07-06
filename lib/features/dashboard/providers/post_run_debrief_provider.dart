import 'package:kynos/domain/entities/health_summary.dart';
import 'package:kynos/domain/usecases/gamification/compute_xp_usecase.dart';
import 'package:kynos/domain/usecases/insights/generate_post_run_debrief_usecase.dart';
import 'package:kynos/shared/providers/ai_repository_providers.dart';
import 'package:kynos/shared/providers/character_providers.dart';
import 'package:kynos/shared/providers/gamification_providers.dart';
import 'package:kynos/shared/providers/health_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'post_run_debrief_provider.g.dart';

class PostRunDebriefState {
  const PostRunDebriefState({
    required this.debrief,
    required this.xpAmount,
    required this.workoutId,
  });

  final PostRunDebrief debrief;
  final int xpAmount;
  final String workoutId;
}

@Riverpod(keepAlive: true)
class PostRunDebriefNotifier extends _$PostRunDebriefNotifier {
  static const _prefsKey = 'processed_run_ids';
  final _computeXp = const ComputeXpUseCase();
  final Set<String> _inFlightRunIds = {};

  @override
  AsyncValue<PostRunDebriefState?> build() => const AsyncData(null);

  Future<void> checkLatestRun() async {
    final runs = await ref.read(recentRunsProvider(days: 7, limit: 1).future);
    if (runs.isEmpty) return;

    final latest = runs.first;
    if (_inFlightRunIds.contains(latest.id)) return;

    final processed = await _loadProcessedIds();
    if (processed.contains(latest.id)) return;

    _inFlightRunIds.add(latest.id);
    state = const AsyncLoading();

    try {
      final character = await ref.read(runnerCharacterProvider.future);
      if (character == null) {
        state = const AsyncData(null);
        return;
      }

      final history = await ref.read(healthHistoryProvider(days: 7).future);
      HealthSummary? sameDay;
      for (final s in history) {
        if (s.date.year == latest.end.year &&
            s.date.month == latest.end.month &&
            s.date.day == latest.end.day) {
          sameDay = s;
          break;
        }
      }

      final debrief = await GeneratePostRunDebriefUseCase(
        aiCoach: ref.read(aiCoachRepositoryProvider),
      ).call(session: latest, sameDaySummary: sameDay);

      final xpGain = _computeXp.call(
        session: latest,
        character: character,
        sameDaySummary: sameDay,
      );

      final updated = character.withXpGain(
        xpGain.amount,
        statDeltas: xpGain.statDeltas,
      );
      final saveResult =
          await ref.read(characterRepositoryProvider).saveCharacter(updated);
      if (saveResult != null) {
        state = AsyncError(saveResult, StackTrace.current);
        return;
      }
      ref.invalidate(runnerCharacterProvider);

      await _markProcessed(latest.id, processed);

      state = AsyncData(
        PostRunDebriefState(
          debrief: debrief,
          xpAmount: xpGain.amount,
          workoutId: latest.id,
        ),
      );
    } on Object catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    } finally {
      _inFlightRunIds.remove(latest.id);
    }
  }

  void dismiss() => state = const AsyncData(null);

  Future<Set<String>> _loadProcessedIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_prefsKey)?.toSet() ?? {};
  }

  Future<void> _markProcessed(String id, Set<String> existing) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefsKey, [...existing, id]);
  }
}
