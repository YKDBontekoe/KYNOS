// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'openrouter_models_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(OpenRouterCatalog)
final openRouterCatalogProvider = OpenRouterCatalogProvider._();

final class OpenRouterCatalogProvider
    extends $NotifierProvider<OpenRouterCatalog, OpenRouterCatalogState> {
  OpenRouterCatalogProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'openRouterCatalogProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$openRouterCatalogHash();

  @$internal
  @override
  OpenRouterCatalog create() => OpenRouterCatalog();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OpenRouterCatalogState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OpenRouterCatalogState>(value),
    );
  }
}

String _$openRouterCatalogHash() => r'769eb8817af844f5fae29c81e704588268d2b8e0';

abstract class _$OpenRouterCatalog extends $Notifier<OpenRouterCatalogState> {
  OpenRouterCatalogState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<OpenRouterCatalogState, OpenRouterCatalogState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<OpenRouterCatalogState, OpenRouterCatalogState>,
              OpenRouterCatalogState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(openRouterCatalogData)
final openRouterCatalogDataProvider = OpenRouterCatalogDataProvider._();

final class OpenRouterCatalogDataProvider
    extends
        $FunctionalProvider<
          AsyncValue<({String? error, List<OpenRouterModel>? models})>,
          ({String? error, List<OpenRouterModel>? models}),
          FutureOr<({String? error, List<OpenRouterModel>? models})>
        >
    with
        $FutureModifier<({String? error, List<OpenRouterModel>? models})>,
        $FutureProvider<({String? error, List<OpenRouterModel>? models})> {
  OpenRouterCatalogDataProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'openRouterCatalogDataProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$openRouterCatalogDataHash();

  @$internal
  @override
  $FutureProviderElement<({String? error, List<OpenRouterModel>? models})>
  $createElement($ProviderPointer pointer) => $FutureProviderElement(pointer);

  @override
  FutureOr<({String? error, List<OpenRouterModel>? models})> create(Ref ref) {
    return openRouterCatalogData(ref);
  }
}

String _$openRouterCatalogDataHash() =>
    r'7d1c835dcec80e4d09c284053fe4b321cea806f2';
