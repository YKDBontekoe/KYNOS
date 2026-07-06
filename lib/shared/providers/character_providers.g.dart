// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'character_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Loads the persisted [RunnerCharacter], creating one via class assignment
/// if this is the athlete's first session.
///
/// Kept alive so the character is available app-wide without re-fetching.

@ProviderFor(runnerCharacter)
final runnerCharacterProvider = RunnerCharacterProvider._();

/// Loads the persisted [RunnerCharacter], creating one via class assignment
/// if this is the athlete's first session.
///
/// Kept alive so the character is available app-wide without re-fetching.

final class RunnerCharacterProvider
    extends
        $FunctionalProvider<
          AsyncValue<RunnerCharacter?>,
          RunnerCharacter?,
          FutureOr<RunnerCharacter?>
        >
    with $FutureModifier<RunnerCharacter?>, $FutureProvider<RunnerCharacter?> {
  /// Loads the persisted [RunnerCharacter], creating one via class assignment
  /// if this is the athlete's first session.
  ///
  /// Kept alive so the character is available app-wide without re-fetching.
  RunnerCharacterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'runnerCharacterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$runnerCharacterHash();

  @$internal
  @override
  $FutureProviderElement<RunnerCharacter?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<RunnerCharacter?> create(Ref ref) {
    return runnerCharacter(ref);
  }
}

String _$runnerCharacterHash() => r'8572ed271e26a50f266f30585b438ba8bc4c1b4a';
