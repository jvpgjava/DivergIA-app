import 'package:divergia_app/core/storage/secure_token_storage.dart';
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeSecureStoragePlatform extends FlutterSecureStoragePlatform {
  final Map<String, String> _values = {};

  @override
  Future<bool> containsKey({
    required String key,
    required Map<String, String> options,
  }) async => _values.containsKey(key);

  @override
  Future<void> delete({
    required String key,
    required Map<String, String> options,
  }) async {
    _values.remove(key);
  }

  @override
  Future<void> deleteAll({required Map<String, String> options}) async {
    _values.clear();
  }

  @override
  Future<String?> read({
    required String key,
    required Map<String, String> options,
  }) async => _values[key];

  @override
  Future<Map<String, String>> readAll({
    required Map<String, String> options,
  }) async => Map.of(_values);

  @override
  Future<void> write({
    required String key,
    required String value,
    required Map<String, String> options,
  }) async {
    _values[key] = value;
  }
}

void main() {
  late SecureTokenStorage storage;

  setUp(() {
    FlutterSecureStoragePlatform.instance = _FakeSecureStoragePlatform();
    storage = SecureTokenStorage();
  });

  test('deveRetornarNuloQuandoNenhumTokenFoiSalvo', () async {
    expect(await storage.readAccessToken(), isNull);
  });

  test('deveSalvarELerOTokenDeAcesso', () async {
    await storage.saveAccessToken('token-abc');

    expect(await storage.readAccessToken(), 'token-abc');
  });

  test('deveLimparOTokenSalvo', () async {
    await storage.saveAccessToken('token-abc');

    await storage.clear();

    expect(await storage.readAccessToken(), isNull);
  });
}
