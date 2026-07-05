// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'today_insights_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(todayInsightsState)
final todayInsightsStateProvider = TodayInsightsStateProvider._();

final class TodayInsightsStateProvider
    extends
        $FunctionalProvider<
          AsyncValue<TodayInsightsState>,
          TodayInsightsState,
          FutureOr<TodayInsightsState>
        >
    with
        $FutureModifier<TodayInsightsState>,
        $FutureProvider<TodayInsightsState> {
  TodayInsightsStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'todayInsightsStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$todayInsightsStateHash();

  @$internal
  @override
  $FutureProviderElement<TodayInsightsState> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<TodayInsightsState> create(Ref ref) {
    return todayInsightsState(ref);
  }
}

String _$todayInsightsStateHash() =>
    r'314e21ca3f0849466a961931813a185e684e6b96';
