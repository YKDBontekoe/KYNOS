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
    extends $NotifierProvider<ModelSetupNotifier, AsyncValue<bool>> {
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
  Override overrideWithValue(AsyncValue<bool> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<bool>>(value),
    );
  }
}

String _$modelSetupNotifierHash() =>
    r'f39bac7d86cd6dc2f119dec56255edeea53969cc';

abstract class _$ModelSetupNotifier extends $Notifier<AsyncValue<bool>> {
  AsyncValue<bool> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<bool>, AsyncValue<bool>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<bool>, AsyncValue<bool>>,
              AsyncValue<bool>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
