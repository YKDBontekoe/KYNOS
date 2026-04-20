import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kynos/domain/repositories/health_repository.dart';
import 'package:kynos/infrastructure/health/health_infrastructure_providers.dart';

final sharedHealthRepositoryProvider = Provider<HealthRepository>((ref) {
  return ref.watch(healthKitRepositoryProvider);
});
