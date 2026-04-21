// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quest_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$dailyQuestsHash() => r'48df34152a4fe57a3c5bfca8ce4c51e4175b137b';

/// Returns today's active quests, generating new ones via AI if none exist.
///
/// Copied from [dailyQuests].
@ProviderFor(dailyQuests)
final dailyQuestsProvider = FutureProvider<List<Quest>>.internal(
  dailyQuests,
  name: r'dailyQuestsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$dailyQuestsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DailyQuestsRef = FutureProviderRef<List<Quest>>;
String _$questNotifierHash() => r'bb016bf165b0f2404881f4d3411b8a8da823e1bf';

/// Notifier that allows quest status mutations (complete / expire).
///
/// Copied from [QuestNotifier].
@ProviderFor(QuestNotifier)
final questNotifierProvider =
    AsyncNotifierProvider<QuestNotifier, List<Quest>>.internal(
      QuestNotifier.new,
      name: r'questNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$questNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$QuestNotifier = AsyncNotifier<List<Quest>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
