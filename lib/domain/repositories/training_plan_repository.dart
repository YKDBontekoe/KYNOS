import 'package:kynos/core/errors/failures.dart';
import 'package:kynos/domain/entities/coach/training_plan.dart';

/// Local persistence for the active training plan and adherence.
abstract class TrainingPlanRepository {
  Future<({TrainingPlan? value, Failure? failure})> loadActive();

  Future<({bool? value, Failure? failure})> save(TrainingPlan plan);

  Future<({bool? value, Failure? failure})> clear();
}
