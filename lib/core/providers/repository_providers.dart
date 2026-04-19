import 'package:kynos/domain/repositories/health_repository.dart';
import 'package:kynos/infrastructure/health/health_kit_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'repository_providers.g.dart';

@Riverpod(keepAlive: true)
HealthRepository healthRepository(HealthRepositoryRef ref) {
  return HealthKitRepository();
}
