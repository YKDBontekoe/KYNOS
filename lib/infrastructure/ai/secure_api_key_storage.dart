import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persists sensitive API keys outside SharedPreferences.
class SecureApiKeyStorage {
  SecureApiKeyStorage({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
            );

  static const _openRouterKey = 'openrouter_api_key';

  final FlutterSecureStorage _storage;

  Future<String?> readOpenRouterKey() => _storage.read(key: _openRouterKey);

  Future<void> writeOpenRouterKey(String key) =>
      _storage.write(key: _openRouterKey, value: key);

  Future<void> deleteOpenRouterKey() => _storage.delete(key: _openRouterKey);

  Future<bool> hasOpenRouterKey() async {
    final key = await readOpenRouterKey();
    return key != null && key.isNotEmpty;
  }
}
