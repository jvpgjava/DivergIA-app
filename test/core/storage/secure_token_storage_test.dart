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

  test('deveRetornarNuloQuandoNenhumaSessaoFoiSalva', () async {
    expect(await storage.readAccessToken(), isNull);
  });

  test('deveSalvarELerOTokenDeAcesso', () async {
    await storage.saveSession(accessToken: 'token-abc');

    expect(await storage.readAccessToken(), 'token-abc');
  });

  test('deveLimparASessaoSalvaInclusiveADataDeExpiracaoDasVersoesAntigas', () async {
    await storage.saveSession(accessToken: 'token-abc');
    await FlutterSecureStoragePlatform.instance.write(
      key: 'access_token_expira_em',
      value: '2030-01-01T00:00:00.000Z',
      options: const {},
    );

    await storage.clear();

    expect(await storage.readAccessToken(), isNull);
    expect(
      await FlutterSecureStoragePlatform.instance.read(
        key: 'access_token_expira_em',
        options: const {},
      ),
      isNull,
    );
  });
}
