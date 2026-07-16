// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'training_plan_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(trainingPlanRepository)
final trainingPlanRepositoryProvider = TrainingPlanRepositoryProvider._();

final class TrainingPlanRepositoryProvider
    extends
        $FunctionalProvider<
          TrainingPlanRepository,
          TrainingPlanRepository,
          TrainingPlanRepository
        >
    with $Provider<TrainingPlanRepository> {
  TrainingPlanRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'trainingPlanRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$trainingPlanRepositoryHash();

  @$internal
  @override
  $ProviderElement<TrainingPlanRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  TrainingPlanRepository create(Ref ref) {
    return trainingPlanRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TrainingPlanRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TrainingPlanRepository>(value),
    );
  }
}

String _$trainingPlanRepositoryHash() =>
    r'e11c424afe005d20f06f29c0cb3d63a5cb13a62f';

@ProviderFor(TrainingPlanData)
final trainingPlanDataProvider = TrainingPlanDataProvider._();

final class TrainingPlanDataProvider
    extends $AsyncNotifierProvider<TrainingPlanData, TrainingPlan?> {
  TrainingPlanDataProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'trainingPlanDataProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$trainingPlanDataHash();

  @$internal
  @override
  TrainingPlanData create() => TrainingPlanData();
}

String _$trainingPlanDataHash() => r'483183b4dd499455d784c808bc8cc9eff5ebe1ac';

abstract class _$TrainingPlanData extends $AsyncNotifier<TrainingPlan?> {
  FutureOr<TrainingPlan?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<TrainingPlan?>, TrainingPlan?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<TrainingPlan?>, TrainingPlan?>,
              AsyncValue<TrainingPlan?>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(todayDirective)
final todayDirectiveProvider = TodayDirectiveProvider._();

final class TodayDirectiveProvider
    extends $FunctionalProvider<TodayDirective, TodayDirective, TodayDirective>
    with $Provider<TodayDirective> {
  TodayDirectiveProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'todayDirectiveProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$todayDirectiveHash();

  @$internal
  @override
  $ProviderElement<TodayDirective> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TodayDirective create(Ref ref) {
    return todayDirective(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TodayDirective value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TodayDirective>(value),
    );
  }
}

String _$todayDirectiveHash() => r'cfecb4d87d105aeac43f9154218149ad21579e8f';

@ProviderFor(CoachAccountability)
final coachAccountabilityProvider = CoachAccountabilityProvider._();

final class CoachAccountabilityProvider
    extends $NotifierProvider<CoachAccountability, CoachAccountabilityState> {
  CoachAccountabilityProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'coachAccountabilityProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$coachAccountabilityHash();

  @$internal
  @override
  CoachAccountability create() => CoachAccountability();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CoachAccountabilityState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CoachAccountabilityState>(value),
    );
  }
}

String _$coachAccountabilityHash() =>
    r'4bf995f1a5d9cd608a504eab7ed4ed3cbd71a63e';

abstract class _$CoachAccountability
    extends $Notifier<CoachAccountabilityState> {
  CoachAccountabilityState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<CoachAccountabilityState, CoachAccountabilityState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CoachAccountabilityState, CoachAccountabilityState>,
              CoachAccountabilityState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
