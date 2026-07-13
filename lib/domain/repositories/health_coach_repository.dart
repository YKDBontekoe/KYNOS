import 'package:kynos/core/errors/failures.dart';
import 'package:kynos/domain/entities/health/health_coach_models.dart';

abstract interface class HealthCoachRepository {
  Future<({HealthCoachState? value, Failure? failure})> load();

  Future<({bool value, Failure? failure})> save(HealthCoachState state);

  Future<({bool value, Failure? failure})> clear();
}
