import 'package:flutter_test/flutter_test.dart';
import 'package:kynos/domain/entities/coach/morning_check_in.dart';
import 'package:kynos/domain/entities/health_summary.dart';
import 'package:kynos/domain/usecases/coach/build_daily_coach_brief_usecase.dart';

void main() {
  const useCase = BuildDailyCoachBriefUseCase();

  test('biases toward recovery when subjective fatigue is high', () {
    final brief = useCase(
      history: [
        HealthSummary(
          date: DateTime(2026, 7, 9),
          sleepHours: 7.5,
          hrvMs: 55,
          rhrBpm: 52,
        ),
      ],
      recentRuns: const [],
      checkIn: MorningCheckIn(
        date: DateTime(2026, 7, 9),
        fatigue: 8,
        soreness: 3,
        motivation: 5,
      ),
    );

    expect(brief.recommendation, contains('recovery-biased'));
    expect(brief.evidence, contains('check-in fatigue 8/10, soreness 3/10'));
  });

  test('reports limited confidence when the data is sparse', () {
    final brief = useCase(
      history: [HealthSummary(date: DateTime(2026, 7, 9))],
      recentRuns: const [],
    );

    expect(brief.confidence, 'low');
    expect(brief.dataQuality, 'limited');
    expect(brief.recommendation, contains('normal training'));
  });
}
