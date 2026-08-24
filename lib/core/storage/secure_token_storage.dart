import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Wrapper sobre [FlutterSecureStorage] para o token JWT — Keychain no iOS,
/// Keystore/EncryptedSharedPreferences no Android. Nunca usar
/// `shared_preferences` puro nem variável estática para o token (checklist
/// de segurança do roadmap).
class SecureTokenStorage {
  SecureTokenStorage({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const _accessTokenKey = 'access_token';
  static const _expiraEmKey = 'access_token_expira_em';

  final FlutterSecureStorage _storage;

  Future<String?> readAccessToken() => _storage.read(key: _accessTokenKey);

  /// `null` se não houver sessão salva, ou se a data salva estiver corrompida
  /// (nesse caso a sessão é tratada como inexistente).
  Future<DateTime?> readExpiraEm() async {
    final raw = await _storage.read(key: _expiraEmKey);
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }

  Future<void> saveSession({
    required String accessToken,
    required DateTime expiraEm,
  }) => Future.wait([
    _storage.write(key: _accessTokenKey, value: accessToken),
    _storage.write(key: _expiraEmKey, value: expiraEm.toIso8601String()),
  ]);

  Future<void> clear() => Future.wait([
    _storage.delete(key: _accessTokenKey),
    _storage.delete(key: _expiraEmKey),
  ]);
}

final secureTokenStorageProvider = Provider<SecureTokenStorage>((ref) {
  return SecureTokenStorage();
});
