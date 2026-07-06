// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model_setup_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ModelSetupNotifier)
final modelSetupProvider = ModelSetupNotifierProvider._();

final class ModelSetupNotifierProvider
    extends $NotifierProvider<ModelSetupNotifier, AsyncValue<ModelSetupState>> {
  ModelSetupNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'modelSetupProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$modelSetupNotifierHash();

  @$internal
  @override
  ModelSetupNotifier create() => ModelSetupNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<ModelSetupState> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<ModelSetupState>>(value),
    );
  }
}

String _$modelSetupNotifierHash() =>
    r'f1840224ae7ee109bbe754cd80658f8bb14ab9bb';

abstract class _$ModelSetupNotifier
    extends $Notifier<AsyncValue<ModelSetupState>> {
  AsyncValue<ModelSetupState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<ModelSetupState>, AsyncValue<ModelSetupState>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<ModelSetupState>,
                AsyncValue<ModelSetupState>
              >,
              AsyncValue<ModelSetupState>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
