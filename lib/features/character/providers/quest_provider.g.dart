// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quest_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Returns today's active quests, generating new ones via AI if none exist.

@ProviderFor(dailyQuests)
final dailyQuestsProvider = DailyQuestsProvider._();

/// Returns today's active quests, generating new ones via AI if none exist.

final class DailyQuestsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Quest>>,
          List<Quest>,
          FutureOr<List<Quest>>
        >
    with $FutureModifier<List<Quest>>, $FutureProvider<List<Quest>> {
  /// Returns today's active quests, generating new ones via AI if none exist.
  DailyQuestsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dailyQuestsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dailyQuestsHash();

  @$internal
  @override
  $FutureProviderElement<List<Quest>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Quest>> create(Ref ref) {
    return dailyQuests(ref);
  }
}

String _$dailyQuestsHash() => r'23a2afa81424df60116a928eb212ca6c1c9d866b';

/// Notifier that allows quest status mutations (complete / expire).

@ProviderFor(QuestNotifier)
final questProvider = QuestNotifierProvider._();

/// Notifier that allows quest status mutations (complete / expire).
final class QuestNotifierProvider
    extends $AsyncNotifierProvider<QuestNotifier, List<Quest>> {
  /// Notifier that allows quest status mutations (complete / expire).
  QuestNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'questProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$questNotifierHash();

  @$internal
  @override
  QuestNotifier create() => QuestNotifier();
}

String _$questNotifierHash() => r'9045d3dfe22f044948c2b6e2b11a012150f41e6f';

/// Notifier that allows quest status mutations (complete / expire).

abstract class _$QuestNotifier extends $AsyncNotifier<List<Quest>> {
  FutureOr<List<Quest>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Quest>>, List<Quest>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Quest>>, List<Quest>>,
              AsyncValue<List<Quest>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
