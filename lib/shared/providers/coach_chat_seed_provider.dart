import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'coach_chat_seed_provider.g.dart';

/// Optional seed message injected when opening coach chat from the dashboard.
@Riverpod(keepAlive: true)
class CoachChatSeed extends _$CoachChatSeed {
  @override
  String? build() => null;

  void setSeed(String? message) => state = message;

  String? consumeSeed() {
    final seed = state;
    state = null;
    return seed;
  }
}
