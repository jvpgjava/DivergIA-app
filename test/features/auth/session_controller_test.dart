import 'package:divergia_app/core/storage/secure_token_storage.dart';
import 'package:divergia_app/features/auth/presentation/session_controller.dart';
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

  // Sem a espera mínima de splash aqui — ela é puramente de UX (ver
  // `_duracaoMinimaSplash` em [SessionController]), e deixá-la no valor
  // padrão faria cada teste esperar de verdade ~1s à toa.
  SessionController criarController() =>
      SessionController(storage, duracaoMinimaSplash: Duration.zero);

  test('deveComecarEmCheckingAntesDeVerificarASessao', () {
    final controller = criarController();

    expect(controller.status, SessionStatus.checking);
  });

  test('deveFicarUnauthenticatedQuandoNaoHaTokenSalvo', () async {
    final controller = criarController();

    await controller.checkSession();

    expect(controller.status, SessionStatus.unauthenticated);
  });

  test('deveFicarAuthenticatedQuandoHaTokenValido', () async {
    await storage.saveSession(
      accessToken: 'token-abc',
      expiraEm: DateTime.now().add(const Duration(minutes: 15)),
    );
    final controller = criarController();

    await controller.checkSession();

    expect(controller.status, SessionStatus.authenticated);
  });

  test(
    'deveFicarUnauthenticatedELimparStorageQuandoTokenEstaExpirado',
    () async {
      await storage.saveSession(
        accessToken: 'token-vencido',
        expiraEm: DateTime.now().subtract(const Duration(minutes: 1)),
      );
      final controller = criarController();

      await controller.checkSession();

      expect(controller.status, SessionStatus.unauthenticated);
      expect(await storage.readAccessToken(), isNull);
    },
  );

  test('onLoginSuccessDeveSalvarSessaoEFicarAuthenticated', () async {
    final controller = criarController();
    await controller.checkSession();

    await controller.onLoginSuccess(
      accessToken: 'novo-token',
      expiraEm: DateTime.now().add(const Duration(minutes: 15)),
    );

    expect(controller.status, SessionStatus.authenticated);
    expect(await storage.readAccessToken(), 'novo-token');
  });

  test('onLogoutDeveLimparSessaoEFicarUnauthenticated', () async {
    await storage.saveSession(
      accessToken: 'token-abc',
      expiraEm: DateTime.now().add(const Duration(minutes: 15)),
    );
    final controller = criarController();
    await controller.checkSession();

    await controller.onLogout();

    expect(controller.status, SessionStatus.unauthenticated);
    expect(await storage.readAccessToken(), isNull);
  });

  test('deveNotificarOuvintesQuandoOStatusMuda', () async {
    final controller = criarController();
    var notificacoes = 0;
    controller.addListener(() => notificacoes++);

    await controller.checkSession();

    expect(notificacoes, greaterThanOrEqualTo(1));
  });
}
