// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'training_insights_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(trainingInsightsState)
final trainingInsightsStateProvider = TrainingInsightsStateProvider._();

final class TrainingInsightsStateProvider
    extends
        $FunctionalProvider<
          AsyncValue<TrainingInsightsState>,
          TrainingInsightsState,
          FutureOr<TrainingInsightsState>
        >
    with
        $FutureModifier<TrainingInsightsState>,
        $FutureProvider<TrainingInsightsState> {
  TrainingInsightsStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'trainingInsightsStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$trainingInsightsStateHash();

  @$internal
  @override
  $FutureProviderElement<TrainingInsightsState> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<TrainingInsightsState> create(Ref ref) {
    return trainingInsightsState(ref);
  }
}

String _$trainingInsightsStateHash() =>
    r'f1d578f2194f9103149251dd7370d8cdc1c5211f';
