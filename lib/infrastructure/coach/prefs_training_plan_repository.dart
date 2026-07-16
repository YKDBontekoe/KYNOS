import 'dart:convert';

import 'package:kynos/core/errors/failures.dart';
import 'package:kynos/domain/entities/coach/training_plan.dart';
import 'package:kynos/domain/repositories/training_plan_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrefsTrainingPlanRepository implements TrainingPlanRepository {
  const PrefsTrainingPlanRepository(this._prefs);

  static const storageKey = 'training_plan_v1';

  final SharedPreferences _prefs;

  @override
  Future<({TrainingPlan? value, Failure? failure})> loadActive() async {
    try {
      final raw = _prefs.getString(storageKey);
      if (raw == null || raw.isEmpty) {
        return (value: null, failure: null);
      }
      final decoded = jsonDecode(raw);
      if (decoded is! Map) {
        return (
          value: null,
          failure: const StorageFailure('Invalid local training plan data.'),
        );
      }
      final plan = TrainingPlan.fromJson(Map<String, Object?>.from(decoded));
      if (!plan.active) return (value: null, failure: null);
      return (value: plan, failure: null);
    } on Object catch (error) {
      return (value: null, failure: StorageFailure(error.toString()));
    }
  }

  @override
  Future<({bool? value, Failure? failure})> save(TrainingPlan plan) async {
    try {
      final saved = await _prefs.setString(
        storageKey,
        jsonEncode(plan.toJson()),
      );
      return saved
          ? (value: true, failure: null)
          : (
              value: null,
              failure: const StorageFailure('Could not save training plan.'),
            );
    } on Object catch (error) {
      return (value: null, failure: StorageFailure(error.toString()));
    }
  }

  @override
  Future<({bool? value, Failure? failure})> clear() async {
    try {
      return (value: await _prefs.remove(storageKey), failure: null);
    } on Object catch (error) {
      return (value: null, failure: StorageFailure(error.toString()));
    }
  }
}
