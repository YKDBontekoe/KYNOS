// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_coach_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(healthCoachRepository)
final healthCoachRepositoryProvider = HealthCoachRepositoryProvider._();

final class HealthCoachRepositoryProvider
    extends
        $FunctionalProvider<
          HealthCoachRepository,
          HealthCoachRepository,
          HealthCoachRepository
        >
    with $Provider<HealthCoachRepository> {
  HealthCoachRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'healthCoachRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$healthCoachRepositoryHash();

  @$internal
  @override
  $ProviderElement<HealthCoachRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  HealthCoachRepository create(Ref ref) {
    return healthCoachRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HealthCoachRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HealthCoachRepository>(value),
    );
  }
}

String _$healthCoachRepositoryHash() =>
    r'ad84862778c17765639abce0e89d6f183899e446';

@ProviderFor(HealthCoachData)
final healthCoachDataProvider = HealthCoachDataProvider._();

final class HealthCoachDataProvider
    extends $AsyncNotifierProvider<HealthCoachData, HealthCoachState> {
  HealthCoachDataProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'healthCoachDataProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$healthCoachDataHash();

  @$internal
  @override
  HealthCoachData create() => HealthCoachData();
}

String _$healthCoachDataHash() => r'19afdbede62f5892261de88094a8654a44acc5ba';

abstract class _$HealthCoachData extends $AsyncNotifier<HealthCoachState> {
  FutureOr<HealthCoachState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<HealthCoachState>, HealthCoachState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<HealthCoachState>, HealthCoachState>,
              AsyncValue<HealthCoachState>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(dailyHealthBrief)
final dailyHealthBriefProvider = DailyHealthBriefProvider._();

final class DailyHealthBriefProvider
    extends
        $FunctionalProvider<
          AsyncValue<DailyHealthBrief>,
          DailyHealthBrief,
          FutureOr<DailyHealthBrief>
        >
    with $FutureModifier<DailyHealthBrief>, $FutureProvider<DailyHealthBrief> {
  DailyHealthBriefProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dailyHealthBriefProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dailyHealthBriefHash();

  @$internal
  @override
  $FutureProviderElement<DailyHealthBrief> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<DailyHealthBrief> create(Ref ref) {
    return dailyHealthBrief(ref);
  }
}

String _$dailyHealthBriefHash() => r'255cfa33d38d02022e440d0c84e2635db8e79c9d';

@ProviderFor(experimentProposal)
final experimentProposalProvider = ExperimentProposalFamily._();

final class ExperimentProposalProvider
    extends
        $FunctionalProvider<
          PendingCoachAction,
          PendingCoachAction,
          PendingCoachAction
        >
    with $Provider<PendingCoachAction> {
  ExperimentProposalProvider._({
    required ExperimentProposalFamily super.from,
    required ({
      String title,
      String action,
      String hypothesis,
      int durationDays,
    })
    super.argument,
  }) : super(
         retry: null,
         name: r'experimentProposalProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$experimentProposalHash();

  @override
  String toString() {
    return r'experimentProposalProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $ProviderElement<PendingCoachAction> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PendingCoachAction create(Ref ref) {
    final argument =
        this.argument
            as ({
              String title,
              String action,
              String hypothesis,
              int durationDays,
            });
    return experimentProposal(
      ref,
      title: argument.title,
      action: argument.action,
      hypothesis: argument.hypothesis,
      durationDays: argument.durationDays,
    );
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PendingCoachAction value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PendingCoachAction>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ExperimentProposalProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$experimentProposalHash() =>
    r'9f4fe6567d8efd9f96eba2d4cbbabb07a1ea88bc';

final class ExperimentProposalFamily extends $Family
    with
        $FunctionalFamilyOverride<
          PendingCoachAction,
          ({String title, String action, String hypothesis, int durationDays})
        > {
  ExperimentProposalFamily._()
    : super(
        retry: null,
        name: r'experimentProposalProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ExperimentProposalProvider call({
    required String title,
    required String action,
    required String hypothesis,
    int durationDays = 7,
  }) => ExperimentProposalProvider._(
    argument: (
      title: title,
      action: action,
      hypothesis: hypothesis,
      durationDays: durationDays,
    ),
    from: this,
  );

  @override
  String toString() => r'experimentProposalProvider';
}
