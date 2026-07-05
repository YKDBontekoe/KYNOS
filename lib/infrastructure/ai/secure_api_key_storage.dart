import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persists sensitive API keys outside SharedPreferences.
class SecureApiKeyStorage {
  SecureApiKeyStorage({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
            );

  static const _openRouterKey = 'openrouter_api_key';
  static const _huggingFaceTokenKey = 'huggingface_token';

  final FlutterSecureStorage _storage;

  Future<String?> readOpenRouterKey() => _storage.read(key: _openRouterKey);

  Future<void> writeOpenRouterKey(String key) =>
      _storage.write(key: _openRouterKey, value: key);

  Future<void> deleteOpenRouterKey() => _storage.delete(key: _openRouterKey);

  Future<bool> hasOpenRouterKey() async {
    final key = await readOpenRouterKey();
    return key != null && key.isNotEmpty;
  }

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
