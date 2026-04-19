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

  // HealthKit requires authorization to be requested before querying types!
  // This safely triggers the permissions dialog if not previously granted.
  await repository.requestPermissions();

  // Attempt to fetch today's data. If we don't have permissions yet, 
  // Apple HealthKit will quietly return an empty dataset, and our UI 
  // will gracefully display the "Connect HealthKit" fallback card.
  final result = await repository.getToday();
  if (result.failure != null) {
    throw result.failure!;
  }

  return result.summary;
}
