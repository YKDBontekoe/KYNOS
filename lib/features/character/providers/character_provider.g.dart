// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'character_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$runnerCharacterHash() => r'40ecf158e5dbf13bedb047fa4e7d1d50d9eacc24';

/// Loads the persisted [RunnerCharacter], creating one via class assignment
/// if this is the athlete's first session.
///
/// Kept alive so the character is available app-wide without re-fetching.
///
/// Copied from [runnerCharacter].
@ProviderFor(runnerCharacter)
final runnerCharacterProvider = FutureProvider<RunnerCharacter?>.internal(
  runnerCharacter,
  name: r'runnerCharacterProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$runnerCharacterHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RunnerCharacterRef = FutureProviderRef<RunnerCharacter?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
