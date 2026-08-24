import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Wrapper sobre [FlutterSecureStorage] para o token JWT — Keychain no iOS,
/// Keystore/EncryptedSharedPreferences no Android. Nunca usar
/// `shared_preferences` puro nem variável estática para o token (checklist
/// de segurança do roadmap).
class SecureTokenStorage {
  SecureTokenStorage({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const _accessTokenKey = 'access_token';

  final FlutterSecureStorage _storage;

  Future<String?> readAccessToken() => _storage.read(key: _accessTokenKey);

  Future<void> saveAccessToken(String token) =>
      _storage.write(key: _accessTokenKey, value: token);

  Future<void> clear() => _storage.delete(key: _accessTokenKey);
}
