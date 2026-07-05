import 'package:kynos/shared/providers/openrouter_api_key_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'huggingface_token_provider.g.dart';

@riverpod
Future<String?> readHuggingFaceToken(Ref ref) =>
    ref.watch(huggingFaceTokenManagerProvider.future);

@Riverpod(keepAlive: true)
class HuggingFaceTokenManager extends _$HuggingFaceTokenManager {
  @override
  Future<String?> build() =>
      ref.read(secureApiKeyStorageProvider).readHuggingFaceToken();

  Future<void> save(String token) async {
    await ref.read(secureApiKeyStorageProvider).writeHuggingFaceToken(token);
    state = AsyncData(token);
  }

  Future<void> clear() async {
    await ref.read(secureApiKeyStorageProvider).deleteHuggingFaceToken();
    state = const AsyncData(null);
  }
}
