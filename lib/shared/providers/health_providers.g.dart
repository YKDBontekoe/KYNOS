// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$healthRepositoryHash() => r'85a5a1d14810ce88ec8b9aab64217adc329b7f1f';

/// See also [healthRepository].
@ProviderFor(healthRepository)
final healthRepositoryProvider = Provider<HealthRepository>.internal(
  healthRepository,
  name: r'healthRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$healthRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef HealthRepositoryRef = ProviderRef<HealthRepository>;
String _$healthSummaryHash() => r'a32b97aa6bf12ac07e302436c49090c9685ce3b6';

/// See also [healthSummary].
@ProviderFor(healthSummary)
final healthSummaryProvider =
    AutoDisposeFutureProvider<HealthSummary?>.internal(
      healthSummary,
      name: r'healthSummaryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$healthSummaryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef HealthSummaryRef = AutoDisposeFutureProviderRef<HealthSummary?>;
String _$healthHistoryHash() => r'8480e37dcb743335c30759e6ed903093037f54ef';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [healthHistory].
@ProviderFor(healthHistory)
const healthHistoryProvider = HealthHistoryFamily();

/// See also [healthHistory].
class HealthHistoryFamily extends Family<AsyncValue<List<HealthSummary>>> {
  /// See also [healthHistory].
  const HealthHistoryFamily();

  /// See also [healthHistory].
  HealthHistoryProvider call({int days = 30}) {
    return HealthHistoryProvider(days: days);
  }

  @override
  HealthHistoryProvider getProviderOverride(
    covariant HealthHistoryProvider provider,
  ) {
    return call(days: provider.days);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'healthHistoryProvider';
}

/// See also [healthHistory].
class HealthHistoryProvider
    extends AutoDisposeFutureProvider<List<HealthSummary>> {
  /// See also [healthHistory].
  HealthHistoryProvider({int days = 30})
    : this._internal(
        (ref) => healthHistory(ref as HealthHistoryRef, days: days),
        from: healthHistoryProvider,
        name: r'healthHistoryProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$healthHistoryHash,
        dependencies: HealthHistoryFamily._dependencies,
        allTransitiveDependencies:
            HealthHistoryFamily._allTransitiveDependencies,
        days: days,
      );

  HealthHistoryProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.days,
  }) : super.internal();

  final int days;

  @override
  Override overrideWith(
    FutureOr<List<HealthSummary>> Function(HealthHistoryRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: HealthHistoryProvider._internal(
        (ref) => create(ref as HealthHistoryRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        days: days,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<HealthSummary>> createElement() {
    return _HealthHistoryProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is HealthHistoryProvider && other.days == days;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, days.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin HealthHistoryRef on AutoDisposeFutureProviderRef<List<HealthSummary>> {
  /// The parameter `days` of this provider.
  int get days;
}

class _HealthHistoryProviderElement
    extends AutoDisposeFutureProviderElement<List<HealthSummary>>
    with HealthHistoryRef {
  _HealthHistoryProviderElement(super.provider);

  @override
  int get days => (origin as HealthHistoryProvider).days;
}

String _$recentRunsHash() => r'a545bb02ae2da26a882954d04866b8d89007c75c';

/// See also [recentRuns].
@ProviderFor(recentRuns)
const recentRunsProvider = RecentRunsFamily();

/// See also [recentRuns].
class RecentRunsFamily extends Family<AsyncValue<List<WorkoutSession>>> {
  /// See also [recentRuns].
  const RecentRunsFamily();

  /// See also [recentRuns].
  RecentRunsProvider call({int days = 30, int limit = 20}) {
    return RecentRunsProvider(days: days, limit: limit);
  }

  @override
  RecentRunsProvider getProviderOverride(
    covariant RecentRunsProvider provider,
  ) {
    return call(days: provider.days, limit: provider.limit);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'recentRunsProvider';
}

/// See also [recentRuns].
class RecentRunsProvider
    extends AutoDisposeFutureProvider<List<WorkoutSession>> {
  /// See also [recentRuns].
  RecentRunsProvider({int days = 30, int limit = 20})
    : this._internal(
        (ref) => recentRuns(ref as RecentRunsRef, days: days, limit: limit),
        from: recentRunsProvider,
        name: r'recentRunsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$recentRunsHash,
        dependencies: RecentRunsFamily._dependencies,
        allTransitiveDependencies: RecentRunsFamily._allTransitiveDependencies,
        days: days,
        limit: limit,
      );

  RecentRunsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.days,
    required this.limit,
  }) : super.internal();

  final int days;
  final int limit;

  @override
  Override overrideWith(
    FutureOr<List<WorkoutSession>> Function(RecentRunsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: RecentRunsProvider._internal(
        (ref) => create(ref as RecentRunsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        days: days,
        limit: limit,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<WorkoutSession>> createElement() {
    return _RecentRunsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is RecentRunsProvider &&
        other.days == days &&
        other.limit == limit;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, days.hashCode);
    hash = _SystemHash.combine(hash, limit.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin RecentRunsRef on AutoDisposeFutureProviderRef<List<WorkoutSession>> {
  /// The parameter `days` of this provider.
  int get days;

  /// The parameter `limit` of this provider.
  int get limit;
}

class _RecentRunsProviderElement
    extends AutoDisposeFutureProviderElement<List<WorkoutSession>>
    with RecentRunsRef {
  _RecentRunsProviderElement(super.provider);

  @override
  int get days => (origin as RecentRunsProvider).days;
  @override
  int get limit => (origin as RecentRunsProvider).limit;
}

String _$runRouteHash() => r'bce740d4f9deff4aa919a7468fc1a51055e05934';

/// See also [runRoute].
@ProviderFor(runRoute)
const runRouteProvider = RunRouteFamily();

/// See also [runRoute].
class RunRouteFamily extends Family<AsyncValue<List<WorkoutRoutePoint>>> {
  /// See also [runRoute].
  const RunRouteFamily();

  /// See also [runRoute].
  RunRouteProvider call({required String workoutUuid}) {
    return RunRouteProvider(workoutUuid: workoutUuid);
  }

  @override
  RunRouteProvider getProviderOverride(covariant RunRouteProvider provider) {
    return call(workoutUuid: provider.workoutUuid);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'runRouteProvider';
}

/// See also [runRoute].
class RunRouteProvider
    extends AutoDisposeFutureProvider<List<WorkoutRoutePoint>> {
  /// See also [runRoute].
  RunRouteProvider({required String workoutUuid})
    : this._internal(
        (ref) => runRoute(ref as RunRouteRef, workoutUuid: workoutUuid),
        from: runRouteProvider,
        name: r'runRouteProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$runRouteHash,
        dependencies: RunRouteFamily._dependencies,
        allTransitiveDependencies: RunRouteFamily._allTransitiveDependencies,
        workoutUuid: workoutUuid,
      );

  RunRouteProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.workoutUuid,
  }) : super.internal();

  final String workoutUuid;

  @override
  Override overrideWith(
    FutureOr<List<WorkoutRoutePoint>> Function(RunRouteRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: RunRouteProvider._internal(
        (ref) => create(ref as RunRouteRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        workoutUuid: workoutUuid,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<WorkoutRoutePoint>> createElement() {
    return _RunRouteProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is RunRouteProvider && other.workoutUuid == workoutUuid;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, workoutUuid.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin RunRouteRef on AutoDisposeFutureProviderRef<List<WorkoutRoutePoint>> {
  /// The parameter `workoutUuid` of this provider.
  String get workoutUuid;
}

class _RunRouteProviderElement
    extends AutoDisposeFutureProviderElement<List<WorkoutRoutePoint>>
    with RunRouteRef {
  _RunRouteProviderElement(super.provider);

  @override
  String get workoutUuid => (origin as RunRouteProvider).workoutUuid;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
