// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'last_coach_context_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Last runner context injected into a coach inference turn (for UI badge).

@ProviderFor(LastCoachContext)
final lastCoachContextProvider = LastCoachContextProvider._();

/// Last runner context injected into a coach inference turn (for UI badge).
final class LastCoachContextProvider
    extends $NotifierProvider<LastCoachContext, CoachContext?> {
  /// Last runner context injected into a coach inference turn (for UI badge).
  LastCoachContextProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'lastCoachContextProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$lastCoachContextHash();

  @$internal
  @override
  LastCoachContext create() => LastCoachContext();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CoachContext? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CoachContext?>(value),
    );
  }
}

String _$lastCoachContextHash() => r'25cb719d15232286b07b9287b489fb3a78525ad3';

/// Last runner context injected into a coach inference turn (for UI badge).

abstract class _$LastCoachContext extends $Notifier<CoachContext?> {
  CoachContext? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<CoachContext?, CoachContext?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CoachContext?, CoachContext?>,
              CoachContext?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
