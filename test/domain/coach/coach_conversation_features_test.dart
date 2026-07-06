import 'package:flutter_test/flutter_test.dart';
import 'package:kynos/domain/entities/coach/coach_backend_mode.dart';
import 'package:kynos/domain/entities/coach/coach_context.dart';
import 'package:kynos/domain/entities/coach/coach_context_preferences.dart';
import 'package:kynos/domain/entities/coach/coach_data_source.dart';
import 'package:kynos/domain/usecases/coach/filter_coach_context_usecase.dart';
import 'package:kynos/domain/utils/coach_backend_mode_mapper.dart';
import 'package:kynos/domain/utils/coach_follow_up_suggestions.dart';

void main() {
  group('FilterCoachContextUseCase', () {
    const useCase = FilterCoachContextUseCase();
    final context = CoachContext(
      readinessScore: 72,
      readinessSummary: 'Good',
      healthHistory: const [],
      recentRuns: const [],
      postRunDebriefSummary: 'Strong finish',
    );

    test('disables post-run debrief when source toggled off', () {
      final filtered = useCase.call(
        context: context,
        preferences: CoachContextPreferences(
          enabledSources: {CoachDataSource.readinessAcwr},
        ),
      );

      expect(filtered.postRunDebriefSummary, isNull);
      expect(filtered.readinessScore, 72);
    });
  });

  group('CoachBackendModeMapper', () {
    test('maps cloud mode to openRouter backend', () {
      expect(
        CoachBackendModeMapper.toPreferredBackend(CoachBackendMode.cloud),
        isNotNull,
      );
    });

    test('auto mode returns null preferred backend', () {
      expect(
        CoachBackendModeMapper.toPreferredBackend(CoachBackendMode.auto),
        isNull,
      );
    });
  });

  group('CoachFollowUpSuggestions', () {
    test('returns at most three suggestions', () {
      final suggestions = CoachFollowUpSuggestions.forContext(
        enabledSources: CoachDataSource.all.toSet(),
      );
      expect(suggestions.length, lessThanOrEqualTo(3));
      expect(suggestions, isNotEmpty);
    });
  });
}
