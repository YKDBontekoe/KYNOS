import 'package:kynos/domain/entities/health_summary.dart';
import 'package:kynos/domain/repositories/health_repository.dart';
import 'package:kynos/shared/providers/health_repository_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'health_provider.g.dart';

@Riverpod(keepAlive: true)
HealthRepository healthRepository(HealthRepositoryRef ref) {
  // Delegate to the infrastructure binding — feature layer stays decoupled
  // from the concrete HealthKitRepository class.
  return ref.watch(sharedHealthRepositoryProvider);
}

@riverpod
Future<HealthSummary?> healthSummary(HealthSummaryRef ref) async {
  final repository = ref.watch(healthRepositoryProvider);

  final result = await repository.getToday();
  // Fail closed to "no data" so the dashboard still renders and can show
  // the explicit Connect HealthKit call-to-action.
  if (result.failure != null) return null;
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
