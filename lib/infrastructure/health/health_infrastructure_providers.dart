import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kynos/domain/repositories/health_repository.dart';
import 'package:kynos/infrastructure/health/health_kit_repository.dart';

/// Platform binding for Apple HealthKit.
///
/// Named [healthKitRepositoryProvider] (not [healthRepositoryProvider]) to
/// avoid shadowing the code-generated provider in the feature layer.
/// The feature layer delegates to this binding without importing the concrete
/// [HealthKitRepository] class itself.
final healthKitRepositoryProvider = Provider<HealthRepository>((ref) {
  return HealthKitRepository();
});
