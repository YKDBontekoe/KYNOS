// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weekly_adaptation_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Surfaces a confirmable weekly plan-protection action when due.

@ProviderFor(WeeklyAdaptation)
final weeklyAdaptationProvider = WeeklyAdaptationProvider._();

/// Surfaces a confirmable weekly plan-protection action when due.
final class WeeklyAdaptationProvider
    extends $NotifierProvider<WeeklyAdaptation, PendingCoachAction?> {
  /// Surfaces a confirmable weekly plan-protection action when due.
  WeeklyAdaptationProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'weeklyAdaptationProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$weeklyAdaptationHash();

  @$internal
  @override
  WeeklyAdaptation create() => WeeklyAdaptation();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PendingCoachAction? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PendingCoachAction?>(value),
    );
  }
}

String _$weeklyAdaptationHash() => r'67b9f6c4a7a884d990f026b3787bc0bd87e1446b';

/// Surfaces a confirmable weekly plan-protection action when due.

abstract class _$WeeklyAdaptation extends $Notifier<PendingCoachAction?> {
  PendingCoachAction? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<PendingCoachAction?, PendingCoachAction?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PendingCoachAction?, PendingCoachAction?>,
              PendingCoachAction?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
