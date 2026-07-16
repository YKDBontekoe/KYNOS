// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coach_context_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Builds unified runner context for coach inference.

@ProviderFor(coachContext)
final coachContextProvider = CoachContextProvider._();

/// Builds unified runner context for coach inference.

final class CoachContextProvider
    extends
        $FunctionalProvider<
          AsyncValue<CoachContext>,
          CoachContext,
          FutureOr<CoachContext>
        >
    with $FutureModifier<CoachContext>, $FutureProvider<CoachContext> {
  /// Builds unified runner context for coach inference.
  CoachContextProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'coachContextProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$coachContextHash();

  @$internal
  @override
  $FutureProviderElement<CoachContext> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<CoachContext> create(Ref ref) {
    return coachContext(ref);
  }
}

String _$coachContextHash() => r'24bf22a94f792671a44e7e009593ac2e6901ff2d';

@ProviderFor(coachContextForConversation)
final coachContextForConversationProvider =
    CoachContextForConversationFamily._();

final class CoachContextForConversationProvider
    extends
        $FunctionalProvider<
          AsyncValue<CoachContext>,
          CoachContext,
          FutureOr<CoachContext>
        >
    with $FutureModifier<CoachContext>, $FutureProvider<CoachContext> {
  CoachContextForConversationProvider._({
    required CoachContextForConversationFamily super.from,
    required CoachChatSeedData? super.argument,
  }) : super(
         retry: null,
         name: r'coachContextForConversationProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$coachContextForConversationHash();

  @override
  String toString() {
    return r'coachContextForConversationProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<CoachContext> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<CoachContext> create(Ref ref) {
    final argument = this.argument as CoachChatSeedData?;
    return coachContextForConversation(ref, seed: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CoachContextForConversationProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$coachContextForConversationHash() =>
    r'208c38ff65d57b6ca582f1e21ccb6b749a197d7c';

final class CoachContextForConversationFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<CoachContext>, CoachChatSeedData?> {
  CoachContextForConversationFamily._()
    : super(
        retry: null,
        name: r'coachContextForConversationProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CoachContextForConversationProvider call({CoachChatSeedData? seed}) =>
      CoachContextForConversationProvider._(argument: seed, from: this);

  @override
  String toString() => r'coachContextForConversationProvider';
}
