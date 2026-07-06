import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'ai_reconnect_provider.g.dart';

/// Set when the on-device AI isolate was disposed on background; UI may re-init.
@Riverpod(keepAlive: true)
class AiReconnectState extends _$AiReconnectState {
  @override
  bool build() => false;

  void markNeedsReconnect() => state = true;

  void clear() => state = false;
}
