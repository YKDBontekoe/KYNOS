// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'manual_run_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ManualRun)
final manualRunProvider = ManualRunProvider._();

final class ManualRunProvider
    extends $NotifierProvider<ManualRun, ManualRunState> {
  ManualRunProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'manualRunProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$manualRunHash();

  @$internal
  @override
  ManualRun create() => ManualRun();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ManualRunState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ManualRunState>(value),
    );
  }
}

String _$manualRunHash() => r'e3254dde1473742474808bb2290e0705253d20a2';

abstract class _$ManualRun extends $Notifier<ManualRunState> {
  ManualRunState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ManualRunState, ManualRunState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ManualRunState, ManualRunState>,
              ManualRunState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
