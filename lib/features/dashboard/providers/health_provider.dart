import 'package:kynos/core/providers/repository_providers.dart';
import 'package:kynos/domain/entities/health_summary.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'health_provider.g.dart';

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
