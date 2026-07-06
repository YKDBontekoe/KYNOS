// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coach_chat_seed_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Structured seed injected when opening coach chat from another feature.

@ProviderFor(CoachChatSeed)
final coachChatSeedProvider = CoachChatSeedProvider._();

/// Structured seed injected when opening coach chat from another feature.
final class CoachChatSeedProvider
    extends $NotifierProvider<CoachChatSeed, CoachChatSeedData?> {
  /// Structured seed injected when opening coach chat from another feature.
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
  Override overrideWithValue(CoachChatSeedData? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CoachChatSeedData?>(value),
    );
  }
}

String _$coachChatSeedHash() => r'7ddc71f17a2a9fd0dc11f4a2511e9b6704527fa9';

/// Structured seed injected when opening coach chat from another feature.

abstract class _$CoachChatSeed extends $Notifier<CoachChatSeedData?> {
  CoachChatSeedData? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<CoachChatSeedData?, CoachChatSeedData?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CoachChatSeedData?, CoachChatSeedData?>,
              CoachChatSeedData?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
