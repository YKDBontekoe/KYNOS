// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_insight_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$aiDailyInsightHash() => r'cf726c7daeeb745b2f4a32aec79bfbb0345472c4';

/// Generates a single coaching sentence from today's health data using the
/// on-device model. Returns null silently when the model is not installed
/// or when insufficient health data is available.
///
/// Kept alive for the app session — only regenerates when health data changes.
///
/// Copied from [aiDailyInsight].
@ProviderFor(aiDailyInsight)
final aiDailyInsightProvider = FutureProvider<String?>.internal(
  aiDailyInsight,
  name: r'aiDailyInsightProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$aiDailyInsightHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AiDailyInsightRef = FutureProviderRef<String?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
