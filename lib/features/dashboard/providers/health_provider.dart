import 'package:kynos/domain/entities/health_summary.dart';
import 'package:kynos/domain/repositories/health_repository.dart';
import 'package:kynos/infrastructure/health/health_infrastructure_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'health_provider.g.dart';

@Riverpod(keepAlive: true)
HealthRepository healthRepository(HealthRepositoryRef ref) {
  // Delegate to the infrastructure binding — feature layer stays decoupled
  // from the concrete HealthKitRepository class.
  return ref.watch(healthKitRepositoryProvider);
}

@riverpod
Future<HealthSummary?> healthSummary(HealthSummaryRef ref) async {
  final repository = ref.watch(healthRepositoryProvider);

  // HealthKit requires authorisation before querying; this triggers the
  // system dialog on first run and is a no-op on subsequent calls.
  await repository.requestPermissions();

  final result = await repository.getToday();
  if (result.failure != null) {
    throw result.failure!;
  }
  return result.summary;
}

/// Handles the HealthKit permission request triggered from the UI.
///
/// Manually-defined (no code-gen) to avoid regenerating health_provider.g.dart.
/// Invalidates [healthSummaryProvider] on success so the Today tab refreshes.
class HealthPermissionsNotifier extends Notifier<AsyncValue<bool>> {
  @override
  AsyncValue<bool> build() => const AsyncData(false);

  Future<void> request() async {
    state = const AsyncLoading();
    try {
      final repo = ref.read(healthRepositoryProvider);
      final success = await repo.requestPermissions();
      state = AsyncData(success);
      if (success) ref.invalidate(healthSummaryProvider);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

final healthPermissionsNotifierProvider =
    NotifierProvider<HealthPermissionsNotifier, AsyncValue<bool>>(
  HealthPermissionsNotifier.new,
);
