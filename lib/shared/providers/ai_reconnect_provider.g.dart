// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_reconnect_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Set when the on-device AI isolate was disposed on background; UI may re-init.

@ProviderFor(AiReconnectState)
final aiReconnectStateProvider = AiReconnectStateProvider._();

/// Set when the on-device AI isolate was disposed on background; UI may re-init.
final class AiReconnectStateProvider
    extends $NotifierProvider<AiReconnectState, bool> {
  /// Set when the on-device AI isolate was disposed on background; UI may re-init.
  AiReconnectStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'aiReconnectStateProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$aiReconnectStateHash();

  @$internal
  @override
  AiReconnectState create() => AiReconnectState();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$aiReconnectStateHash() => r'7f6c1bd32f1e29f6d5de7fa333eb5293295b6720';

/// Set when the on-device AI isolate was disposed on background; UI may re-init.

abstract class _$AiReconnectState extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
