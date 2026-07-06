// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Canonical health repository binding — merges HealthKit and imported data.

@ProviderFor(healthRepository)
final healthRepositoryProvider = HealthRepositoryProvider._();

/// Canonical health repository binding — merges HealthKit and imported data.

final class HealthRepositoryProvider
    extends
        $FunctionalProvider<
          HealthRepository,
          HealthRepository,
          HealthRepository
        >
    with $Provider<HealthRepository> {
  /// Canonical health repository binding — merges HealthKit and imported data.
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

String _$healthRepositoryHash() => r'51095aae53e7128d9e50c17c82ca68ad06078f67';

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

String _$healthSummaryHash() => r'880dd4f6394edd5093cb6ccf70d030c7a1596978';

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

String _$healthHistoryHash() => r'2d73c0fbb99e3f824adcdd88152e6f6530254ea8';

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

String _$recentRunsHash() => r'fc8420c008a5e6f6cba5e37e9053134a95f67ef7';

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

String _$runRouteHash() => r'7fdc36366f5c9657d0004078707355964ea12bac';

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

@ProviderFor(importedWorkoutCount)
final importedWorkoutCountProvider = ImportedWorkoutCountProvider._();

final class ImportedWorkoutCountProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  ImportedWorkoutCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'importedWorkoutCountProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$importedWorkoutCountHash();

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    return importedWorkoutCount(ref);
  }
}

String _$importedWorkoutCountHash() =>
    r'79c6f4eb66a39c14c27f60e7dacd7aba4604ba0b';

/// Handles the HealthKit permission request triggered from the UI.

@ProviderFor(HealthPermissionsNotifier)
final healthPermissionsProvider = HealthPermissionsNotifierProvider._();

/// Handles the HealthKit permission request triggered from the UI.
final class HealthPermissionsNotifierProvider
    extends $AsyncNotifierProvider<HealthPermissionsNotifier, bool> {
  /// Handles the HealthKit permission request triggered from the UI.
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
}

String _$healthPermissionsNotifierHash() =>
    r'9032f26135d27f6225bc8d8d0d91935411293e7e';

/// Handles the HealthKit permission request triggered from the UI.

abstract class _$HealthPermissionsNotifier extends $AsyncNotifier<bool> {
  FutureOr<bool> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<bool>, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<bool>, bool>,
              AsyncValue<bool>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Clears all imported workouts and refreshes health providers.

@ProviderFor(ImportedHealthDataNotifier)
final importedHealthDataProvider = ImportedHealthDataNotifierProvider._();

/// Clears all imported workouts and refreshes health providers.
final class ImportedHealthDataNotifierProvider
    extends $NotifierProvider<ImportedHealthDataNotifier, AsyncValue<void>> {
  /// Clears all imported workouts and refreshes health providers.
  ImportedHealthDataNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'importedHealthDataProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$importedHealthDataNotifierHash();

  @$internal
  @override
  ImportedHealthDataNotifier create() => ImportedHealthDataNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>>(value),
    );
  }
}

String _$importedHealthDataNotifierHash() =>
    r'd9f4376bc4194731b7580e712e7c7b1443444ce9';

/// Clears all imported workouts and refreshes health providers.

abstract class _$ImportedHealthDataNotifier
    extends $Notifier<AsyncValue<void>> {
  AsyncValue<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, AsyncValue<void>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, AsyncValue<void>>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
