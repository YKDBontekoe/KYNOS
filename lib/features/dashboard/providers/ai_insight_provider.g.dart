// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_insight_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Generates a single coaching sentence from today's health data using the
/// on-device model. Returns null silently when the model is not installed
/// or when insufficient health data is available.

@ProviderFor(aiDailyInsight)
final aiDailyInsightProvider = AiDailyInsightProvider._();

/// Generates a single coaching sentence from today's health data using the
/// on-device model. Returns null silently when the model is not installed
/// or when insufficient health data is available.

final class AiDailyInsightProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, FutureOr<String?>>
    with $FutureModifier<String?>, $FutureProvider<String?> {
  /// Generates a single coaching sentence from today's health data using the
  /// on-device model. Returns null silently when the model is not installed
  /// or when insufficient health data is available.
  AiDailyInsightProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'aiDailyInsightProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$aiDailyInsightHash();

  @$internal
  @override
  $FutureProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String?> create(Ref ref) {
    return aiDailyInsight(ref);
  }
}

String _$aiDailyInsightHash() => r'21feb52fc97285fa72536c242cdee14c63f94dd8';
