import 'dart:convert';

import 'package:kynos/core/errors/failures.dart';
import 'package:kynos/domain/entities/health/health_coach_models.dart';
import 'package:kynos/domain/repositories/health_coach_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrefsHealthCoachRepository implements HealthCoachRepository {
  const PrefsHealthCoachRepository(this._prefs);

  static const storageKey = 'health_coach_state_v1';
  static const _maxCheckIns = 180;
  static const _maxMemories = 100;
  static const _maxExperiments = 50;

  final SharedPreferences _prefs;

  @override
  Future<({HealthCoachState? value, Failure? failure})> load() async {
    try {
      final raw = _prefs.getString(storageKey);
      if (raw == null || raw.isEmpty) {
        return (value: const HealthCoachState(), failure: null);
      }
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, Object?>) {
        return (
          value: const HealthCoachState(),
          failure: const HealthCoachFailure('Invalid local health coach data.'),
        );
      }
      return (value: HealthCoachState.fromJson(decoded), failure: null);
    } on Object catch (error) {
      return (
        value: const HealthCoachState(),
        failure: HealthCoachFailure(error.toString()),
      );
    }
  }

  @override
  Future<({bool value, Failure? failure})> save(HealthCoachState state) async {
    try {
      final bounded = state.copyWith(
        checkIns: state.checkIns.take(_maxCheckIns).toList(growable: false),
        memories: state.memories.take(_maxMemories).toList(growable: false),
        experiments: state.experiments
            .take(_maxExperiments)
            .toList(growable: false),
      );
      final saved = await _prefs.setString(
        storageKey,
        jsonEncode(bounded.toJson()),
      );
      return saved
          ? (value: true, failure: null)
          : (
              value: false,
              failure: const HealthCoachFailure('Could not save locally.'),
            );
    } on Object catch (error) {
      return (value: false, failure: HealthCoachFailure(error.toString()));
    }
  }

  @override
  Future<({bool value, Failure? failure})> clear() async {
    try {
      return (value: await _prefs.remove(storageKey), failure: null);
    } on Object catch (error) {
      return (value: false, failure: HealthCoachFailure(error.toString()));
    }
  }
}
