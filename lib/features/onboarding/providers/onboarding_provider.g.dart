// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$sharedPreferencesHash() => r'9df33a5f4bc681d919954fae74530a60d280d078';

/// Provides a synchronously accessible SharedPreferences instance.
/// This must be overridden with the actual instance in the `ProviderScope` during app initialization.
///
/// Copied from [sharedPreferences].
@ProviderFor(sharedPreferences)
final sharedPreferencesProvider =
    AutoDisposeProvider<SharedPreferences>.internal(
      sharedPreferences,
      name: r'sharedPreferencesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$sharedPreferencesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SharedPreferencesRef = AutoDisposeProviderRef<SharedPreferences>;
String _$onboardingCompletedHash() =>
    r'0738610cb066c977a5815ffffedbec6cb7926fc6';

/// See also [OnboardingCompleted].
@ProviderFor(OnboardingCompleted)
final onboardingCompletedProvider =
    AutoDisposeNotifierProvider<OnboardingCompleted, bool>.internal(
      OnboardingCompleted.new,
      name: r'onboardingCompletedProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$onboardingCompletedHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$OnboardingCompleted = AutoDisposeNotifier<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
