// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'camp_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CampSessionNotifier)
final campSessionProvider = CampSessionNotifierProvider._();

final class CampSessionNotifierProvider
    extends $AsyncNotifierProvider<CampSessionNotifier, CampViewState?> {
  CampSessionNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'campSessionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$campSessionNotifierHash();

  @$internal
  @override
  CampSessionNotifier create() => CampSessionNotifier();
}

String _$campSessionNotifierHash() =>
    r'6a53296f36915e927c1b53f29cbf9cb3b0c0ad6e';

abstract class _$CampSessionNotifier extends $AsyncNotifier<CampViewState?> {
  FutureOr<CampViewState?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<CampViewState?>, CampViewState?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<CampViewState?>, CampViewState?>,
              AsyncValue<CampViewState?>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
