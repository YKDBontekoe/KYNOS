// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_session_lookup_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Resolves a [WorkoutSession] by id for deep-linked run routes.

@ProviderFor(workoutSessionById)
final workoutSessionByIdProvider = WorkoutSessionByIdFamily._();

/// Resolves a [WorkoutSession] by id for deep-linked run routes.

final class WorkoutSessionByIdProvider
    extends
        $FunctionalProvider<
          AsyncValue<WorkoutSession?>,
          WorkoutSession?,
          FutureOr<WorkoutSession?>
        >
    with $FutureModifier<WorkoutSession?>, $FutureProvider<WorkoutSession?> {
  /// Resolves a [WorkoutSession] by id for deep-linked run routes.
  WorkoutSessionByIdProvider._({
    required WorkoutSessionByIdFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'workoutSessionByIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$workoutSessionByIdHash();

  @override
  String toString() {
    return r'workoutSessionByIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<WorkoutSession?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<WorkoutSession?> create(Ref ref) {
    final argument = this.argument as String;
    return workoutSessionById(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is WorkoutSessionByIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$workoutSessionByIdHash() =>
    r'595d1ffa51393fadd72d6845e9b1777a25f3f230';

/// Resolves a [WorkoutSession] by id for deep-linked run routes.

final class WorkoutSessionByIdFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<WorkoutSession?>, String> {
  WorkoutSessionByIdFamily._()
    : super(
        retry: null,
        name: r'workoutSessionByIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Resolves a [WorkoutSession] by id for deep-linked run routes.

  WorkoutSessionByIdProvider call(String runId) =>
      WorkoutSessionByIdProvider._(argument: runId, from: this);

  @override
  String toString() => r'workoutSessionByIdProvider';
}
