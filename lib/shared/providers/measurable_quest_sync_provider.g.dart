// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'measurable_quest_sync_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Keeps measurable daily quests in sync with health data app-wide.

@ProviderFor(MeasurableQuestSync)
final measurableQuestSyncProvider = MeasurableQuestSyncProvider._();

/// Keeps measurable daily quests in sync with health data app-wide.
final class MeasurableQuestSyncProvider
    extends $NotifierProvider<MeasurableQuestSync, void> {
  /// Keeps measurable daily quests in sync with health data app-wide.
  MeasurableQuestSyncProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'measurableQuestSyncProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$measurableQuestSyncHash();

  @$internal
  @override
  MeasurableQuestSync create() => MeasurableQuestSync();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$measurableQuestSyncHash() =>
    r'be5c80f827a1b46a3ed2de4fe942178cca33c6a5';

/// Keeps measurable daily quests in sync with health data app-wide.

abstract class _$MeasurableQuestSync extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
