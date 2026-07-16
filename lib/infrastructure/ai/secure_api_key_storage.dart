import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persists sensitive API keys outside SharedPreferences.
class SecureApiKeyStorage {
  SecureApiKeyStorage({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
            );

  /// Legacy key name — kept so existing OpenRouter installs keep working.
  static const _cloudApiKey = 'openrouter_api_key';
  static const _huggingFaceTokenKey = 'huggingface_token';

  final FlutterSecureStorage _storage;

  Future<String?> readCloudApiKey() => _storage.read(key: _cloudApiKey);

  Future<void> writeCloudApiKey(String key) =>
      _storage.write(key: _cloudApiKey, value: key);

  Future<void> deleteCloudApiKey() => _storage.delete(key: _cloudApiKey);

  Future<bool> hasCloudApiKey() async {
    final key = await readCloudApiKey();
    return key != null && key.isNotEmpty;
  }

  /// @Deprecated — use [readCloudApiKey].
  Future<String?> readOpenRouterKey() => readCloudApiKey();

  /// @Deprecated — use [writeCloudApiKey].
  Future<void> writeOpenRouterKey(String key) => writeCloudApiKey(key);

  /// @Deprecated — use [deleteCloudApiKey].
  Future<void> deleteOpenRouterKey() => deleteCloudApiKey();

  /// @Deprecated — use [hasCloudApiKey].
  Future<bool> hasOpenRouterKey() => hasCloudApiKey();

  Future<String?> readHuggingFaceToken() =>
      _storage.read(key: _huggingFaceTokenKey);

  Future<void> writeHuggingFaceToken(String token) =>
      _storage.write(key: _huggingFaceTokenKey, value: token);

  Future<void> deleteHuggingFaceToken() =>
      _storage.delete(key: _huggingFaceTokenKey);

  Future<bool> hasHuggingFaceToken() async {
    final token = await readHuggingFaceToken();
    return token != null && token.isNotEmpty;
  }
}
