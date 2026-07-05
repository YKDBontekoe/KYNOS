// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(healthRepository)
final healthRepositoryProvider = HealthRepositoryProvider._();

final class HealthRepositoryProvider
    extends
        $FunctionalProvider<
          HealthRepository,
          HealthRepository,
          HealthRepository
        >
    with $Provider<HealthRepository> {
  HealthRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'healthRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$healthRepositoryHash();

  @$internal
  @override
  $ProviderElement<HealthRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  HealthRepository create(Ref ref) {
    return healthRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HealthRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HealthRepository>(value),
    );
  }
}

String _$healthRepositoryHash() => r'08f5fd3e2167cd2b5e03eae58e2bedba0d5d8bb1';

@ProviderFor(healthSummary)
final healthSummaryProvider = HealthSummaryProvider._();

final class HealthSummaryProvider
    extends
        $FunctionalProvider<
          AsyncValue<HealthSummary?>,
          HealthSummary?,
          FutureOr<HealthSummary?>
        >
    with $FutureModifier<HealthSummary?>, $FutureProvider<HealthSummary?> {
  HealthSummaryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'healthSummaryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$healthSummaryHash();

  @$internal
  @override
  $FutureProviderElement<HealthSummary?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<HealthSummary?> create(Ref ref) {
    return healthSummary(ref);
  }
}

String _$healthSummaryHash() => r'7ab14cbcc7e42286995d3587e3dce81faecdb85b';

@ProviderFor(healthHistory)
final healthHistoryProvider = HealthHistoryFamily._();

final class HealthHistoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<HealthSummary>>,
          List<HealthSummary>,
          FutureOr<List<HealthSummary>>
        >
    with
        $FutureModifier<List<HealthSummary>>,
        $FutureProvider<List<HealthSummary>> {
  HealthHistoryProvider._({
    required HealthHistoryFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'healthHistoryProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$healthHistoryHash();

  @override
  String toString() {
    return r'healthHistoryProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<HealthSummary>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<HealthSummary>> create(Ref ref) {
    final argument = this.argument as int;
    return healthHistory(ref, days: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is HealthHistoryProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$healthHistoryHash() => r'3dc9717a6c38228f4f32b0bba128682e5b2c7c94';

final class HealthHistoryFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<HealthSummary>>, int> {
  HealthHistoryFamily._()
    : super(
        retry: null,
        name: r'healthHistoryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  HealthHistoryProvider call({int days = 30}) =>
      HealthHistoryProvider._(argument: days, from: this);

  @override
  String toString() => r'healthHistoryProvider';
}

@ProviderFor(recentRuns)
final recentRunsProvider = RecentRunsFamily._();

final class RecentRunsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<WorkoutSession>>,
          List<WorkoutSession>,
          FutureOr<List<WorkoutSession>>
        >
    with
        $FutureModifier<List<WorkoutSession>>,
        $FutureProvider<List<WorkoutSession>> {
  RecentRunsProvider._({
    required RecentRunsFamily super.from,
    required ({int days, int limit}) super.argument,
  }) : super(
         retry: null,
         name: r'recentRunsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$recentRunsHash();

  @override
  String toString() {
    return r'recentRunsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<WorkoutSession>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<WorkoutSession>> create(Ref ref) {
    final argument = this.argument as ({int days, int limit});
    return recentRuns(ref, days: argument.days, limit: argument.limit);
  }

  @override
  bool operator ==(Object other) {
    return other is RecentRunsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$recentRunsHash() => r'002d6637a291818a9b951cd002140dd0266d155b';

final class RecentRunsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<WorkoutSession>>,
          ({int days, int limit})
        > {
  RecentRunsFamily._()
    : super(
        retry: null,
        name: r'recentRunsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  RecentRunsProvider call({int days = 30, int limit = 20}) =>
      RecentRunsProvider._(argument: (days: days, limit: limit), from: this);

  @override
  String toString() => r'recentRunsProvider';
}

/// Handles the HealthKit permission request triggered from the UI.
///
/// Invalidates health providers on success so dashboard sections refresh.

@ProviderFor(HealthPermissionsNotifier)
final healthPermissionsProvider = HealthPermissionsNotifierProvider._();

/// Handles the HealthKit permission request triggered from the UI.
///
/// Invalidates health providers on success so dashboard sections refresh.
final class HealthPermissionsNotifierProvider
    extends $NotifierProvider<HealthPermissionsNotifier, AsyncValue<bool>> {
  /// Handles the HealthKit permission request triggered from the UI.
  ///
  /// Invalidates health providers on success so dashboard sections refresh.
  HealthPermissionsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'healthPermissionsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$healthPermissionsNotifierHash();

  @$internal
  @override
  HealthPermissionsNotifier create() => HealthPermissionsNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<bool> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<bool>>(value),
    );
  }
}

String _$healthPermissionsNotifierHash() =>
    r'd3b5fb7a299c6341ef5488e78a5c5250b3b5bdb0';

/// Handles the HealthKit permission request triggered from the UI.
///
/// Invalidates health providers on success so dashboard sections refresh.

abstract class _$HealthPermissionsNotifier extends $Notifier<AsyncValue<bool>> {
  AsyncValue<bool> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<bool>, AsyncValue<bool>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<bool>, AsyncValue<bool>>,
              AsyncValue<bool>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(runRoute)
final runRouteProvider = RunRouteFamily._();

final class RunRouteProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<WorkoutRoutePoint>>,
          List<WorkoutRoutePoint>,
          FutureOr<List<WorkoutRoutePoint>>
        >
    with
        $FutureModifier<List<WorkoutRoutePoint>>,
        $FutureProvider<List<WorkoutRoutePoint>> {
  RunRouteProvider._({
    required RunRouteFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'runRouteProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$runRouteHash();

  @override
  String toString() {
    return r'runRouteProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<WorkoutRoutePoint>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<WorkoutRoutePoint>> create(Ref ref) {
    final argument = this.argument as String;
    return runRoute(ref, workoutUuid: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is RunRouteProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$runRouteHash() => r'e4369327187f8124ada5e0ac099a52a2655d0bc9';

final class RunRouteFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<WorkoutRoutePoint>>, String> {
  RunRouteFamily._()
    : super(
        retry: null,
        name: r'runRouteProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  RunRouteProvider call({required String workoutUuid}) =>
      RunRouteProvider._(argument: workoutUuid, from: this);

  @override
  String toString() => r'runRouteProvider';
}
