// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'adventure_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AdventureSessionNotifier)
final adventureSessionProvider = AdventureSessionNotifierProvider._();

final class AdventureSessionNotifierProvider
    extends
        $AsyncNotifierProvider<AdventureSessionNotifier, AdventureViewState?> {
  AdventureSessionNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adventureSessionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adventureSessionNotifierHash();

  @$internal
  @override
  AdventureSessionNotifier create() => AdventureSessionNotifier();
}

String _$adventureSessionNotifierHash() =>
    r'88fc6d7c59036b763a658d37ca13b8c3b4a444d8';

abstract class _$AdventureSessionNotifier
    extends $AsyncNotifier<AdventureViewState?> {
  FutureOr<AdventureViewState?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<AdventureViewState?>, AdventureViewState?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<AdventureViewState?>, AdventureViewState?>,
              AsyncValue<AdventureViewState?>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
