import 'package:kynos/domain/entities/coach/coach_chat_seed.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'coach_chat_seed_provider.g.dart';

/// Structured seed injected when opening coach chat from another feature.
@Riverpod(keepAlive: true)
class CoachChatSeed extends _$CoachChatSeed {
  @override
  CoachChatSeedData? build() => null;

  void setSeed(CoachChatSeedData? seed) => state = seed;

  /// Legacy helper for plain-text seeds.
  void setMessage(String? message) {
    if (message == null || message.trim().isEmpty) {
      state = null;
      return;
    }
    state = CoachChatSeedData(message: message.trim());
  }

  CoachChatSeedData? consumeSeed() {
    final seed = state;
    state = null;
    return seed;
  }
}
