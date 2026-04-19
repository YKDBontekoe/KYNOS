import 'package:kynos/domain/entities/health_summary.dart';
import 'package:kynos/domain/repositories/health_repository.dart';
import 'package:kynos/infrastructure/health/health_kit_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'health_provider.g.dart';

@Riverpod(keepAlive: true)
HealthRepository healthRepository(HealthRepositoryRef ref) {
  // In a real app, we'd switch between HealthKit (iOS) and HealthConnect (Android).
  // For v0.2, we prioritize the iOS HealthKit implementation.
  return HealthKitRepository();
}

@riverpod
Future<HealthSummary?> healthSummary(HealthSummaryRef ref) async {
  final repository = ref.watch(healthRepositoryProvider);
  
  // First, ensure we have permissions.
  final hasPermissions = await repository.requestPermissions();
  if (!hasPermissions) {
    return null;
  }

  final result = await repository.getToday();
  if (result.failure != null) {
    throw result.failure!;
  }
  
  return result.summary;
}
