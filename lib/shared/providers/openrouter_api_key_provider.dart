import 'package:kynos/infrastructure/ai/secure_api_key_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'openrouter_api_key_provider.g.dart';

@Riverpod(keepAlive: true)
SecureApiKeyStorage secureApiKeyStorage(Ref ref) => SecureApiKeyStorage();

@riverpod
Future<String?> readOpenRouterApiKey(Ref ref) {
  return ref.watch(secureApiKeyStorageProvider).readOpenRouterKey();
}

@Riverpod(keepAlive: true)
class OpenRouterApiKeyManager extends _$OpenRouterApiKeyManager {
  @override
  Future<String?> build() =>
      ref.read(secureApiKeyStorageProvider).readOpenRouterKey();

  Future<void> save(String key) async {
    await ref.read(secureApiKeyStorageProvider).writeOpenRouterKey(key);
    state = AsyncData(key);
    ref.invalidate(readOpenRouterApiKeyProvider);
  }

  Future<void> clear() async {
    await ref.read(secureApiKeyStorageProvider).deleteOpenRouterKey();
    state = const AsyncData(null);
    ref.invalidate(readOpenRouterApiKeyProvider);
  }
}
