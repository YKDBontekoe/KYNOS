// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_quests_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Returns today's active quests, generating new ones via AI if none exist.
///
/// Lives in shared so dashboard and character tabs can both consume it
/// without cross-feature provider imports.

@ProviderFor(dailyQuests)
final dailyQuestsProvider = DailyQuestsProvider._();

/// Returns today's active quests, generating new ones via AI if none exist.
///
/// Lives in shared so dashboard and character tabs can both consume it
/// without cross-feature provider imports.

final class DailyQuestsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Quest>>,
          List<Quest>,
          FutureOr<List<Quest>>
        >
    with $FutureModifier<List<Quest>>, $FutureProvider<List<Quest>> {
  /// Returns today's active quests, generating new ones via AI if none exist.
  ///
  /// Lives in shared so dashboard and character tabs can both consume it
  /// without cross-feature provider imports.
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

String _$dailyQuestsHash() => r'deb493b3391351b56b1d981e0a7f11ed3fbb1f23';
