// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nexus_lab_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(NexusLabNotifier)
final nexusLabProvider = NexusLabNotifierProvider._();

final class NexusLabNotifierProvider
    extends $AsyncNotifierProvider<NexusLabNotifier, NexusLabState> {
  NexusLabNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'nexusLabProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$nexusLabNotifierHash();

  @$internal
  @override
  NexusLabNotifier create() => NexusLabNotifier();
}

String _$nexusLabNotifierHash() => r'c718e85eb6cdd8f03fdecfb74d2d20fad7e65d6b';

abstract class _$NexusLabNotifier extends $AsyncNotifier<NexusLabState> {
  FutureOr<NexusLabState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<NexusLabState>, NexusLabState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<NexusLabState>, NexusLabState>,
              AsyncValue<NexusLabState>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
