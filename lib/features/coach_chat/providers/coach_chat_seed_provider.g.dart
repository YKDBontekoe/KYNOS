// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coach_chat_seed_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Optional seed message injected when opening coach chat from the dashboard.

@ProviderFor(CoachChatSeed)
final coachChatSeedProvider = CoachChatSeedProvider._();

/// Optional seed message injected when opening coach chat from the dashboard.
final class CoachChatSeedProvider
    extends $NotifierProvider<CoachChatSeed, String?> {
  /// Optional seed message injected when opening coach chat from the dashboard.
  CoachChatSeedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'coachChatSeedProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$coachChatSeedHash();

  @$internal
  @override
  CoachChatSeed create() => CoachChatSeed();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$coachChatSeedHash() => r'd4401d94d354e9bd6b12eb6d77b695bc56f66a81';

/// Optional seed message injected when opening coach chat from the dashboard.

abstract class _$CoachChatSeed extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
