import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kynos/domain/repositories/health_repository.dart';
import 'package:kynos/infrastructure/health/health_infrastructure_providers.dart';

// Re-exports healthKitRepositoryProvider so feature providers can reference
// it without importing from lib/infrastructure/ directly.
export 'package:kynos/infrastructure/health/health_infrastructure_providers.dart'
    show healthKitRepositoryProvider;

final sharedHealthRepositoryProvider = Provider<HealthRepository>((ref) {
  return ref.watch(healthKitRepositoryProvider);
});
