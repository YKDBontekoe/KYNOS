// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plan_health_sync_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Runs plan auto-adherence + post-run debrief after health data refreshes.

@ProviderFor(PlanHealthSync)
final planHealthSyncProvider = PlanHealthSyncProvider._();

/// Runs plan auto-adherence + post-run debrief after health data refreshes.
final class PlanHealthSyncProvider
    extends $NotifierProvider<PlanHealthSync, int> {
  /// Runs plan auto-adherence + post-run debrief after health data refreshes.
  PlanHealthSyncProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'planHealthSyncProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$planHealthSyncHash();

  @$internal
  @override
  PlanHealthSync create() => PlanHealthSync();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$planHealthSyncHash() => r'db140d6a5d6e50b2c4670e205640a052b990a4bc';

/// Runs plan auto-adherence + post-run debrief after health data refreshes.

abstract class _$PlanHealthSync extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
