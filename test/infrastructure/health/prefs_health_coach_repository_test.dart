import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:kynos/domain/entities/health/health_coach_models.dart';
import 'package:kynos/infrastructure/health/prefs_health_coach_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test(
    'round-trips local check-ins, confirmed memory, and experiments',
    () async {
      SharedPreferences.setMockInitialValues({});
      final repository = PrefsHealthCoachRepository(
        await SharedPreferences.getInstance(),
      );
      final state = HealthCoachState(
        checkIns: [
          HealthCheckIn(
            date: DateTime(2026, 7, 13),
            energy: 4,
            mood: 4,
            stress: 2,
            soreness: 1,
          ),
        ],
        memories: [
          CoachMemory(
            id: 'memory-1',
            fact: 'Morning daylight helps my energy.',
            provenance: 'Confirmed in Coach',
            createdAt: DateTime(2026, 7, 13),
            confirmed: true,
          ),
        ],
        experiments: [
          WellbeingExperiment(
            id: 'experiment-1',
            title: 'Morning daylight',
            action: 'Spend ten minutes outside after waking.',
            hypothesis: 'Morning energy may feel steadier.',
            durationDays: 7,
            createdAt: DateTime(2026, 7, 13),
            status: ExperimentStatus.active,
            outcomeMetrics: const [],
          ),
        ],
      );

      expect((await repository.save(state)).value, isTrue);
      final loaded = await repository.load();

      expect(loaded.failure, isNull);
      expect(loaded.value, state);
    },
  );

  test('recovers safely from malformed versioned JSON', () async {
    SharedPreferences.setMockInitialValues({
      PrefsHealthCoachRepository.storageKey: jsonEncode({'checkIns': 'bad'}),
    });
    final repository = PrefsHealthCoachRepository(
      await SharedPreferences.getInstance(),
    );

    final loaded = await repository.load();

    expect(loaded.value, const HealthCoachState());
    expect(loaded.failure, isNotNull);
  });
}
