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

String _$coachContextHash() => r'fa3d755f04a7090ed9d399e24cddfb1bd699d8d5';
