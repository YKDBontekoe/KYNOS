// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quest_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
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

String _$questNotifierHash() => r'23328e8423ac288338d6a9e123cad819880bce9b';

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
