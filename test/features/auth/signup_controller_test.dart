import 'package:divergia_app/core/network/api_exception.dart';
import 'package:divergia_app/core/storage/secure_token_storage.dart';
import 'package:divergia_app/features/auth/data/auth_api.dart';
import 'package:divergia_app/features/auth/data/models/token_acesso.dart';
import 'package:divergia_app/features/auth/data/models/usuario.dart';
import 'package:divergia_app/features/auth/presentation/session_controller.dart';
import 'package:divergia_app/features/auth/presentation/signup_controller.dart';
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthApi extends Mock implements AuthApi {}

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
  }) async => _values.remove(key);

  @override
  Future<void> deleteAll({required Map<String, String> options}) async =>
      _values.clear();

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
  late _MockAuthApi authApi;
  late SessionController sessionController;
  late SignupController controller;

  setUp(() {
    FlutterSecureStoragePlatform.instance = _FakeSecureStoragePlatform();
    authApi = _MockAuthApi();
    sessionController = SessionController(SecureTokenStorage());
    controller = SignupController(authApi, sessionController);
  });

  test('submitComSucessoDeveCadastrarELogarEmSeguida', () async {
    when(
      () => authApi.cadastrar(
        nome: 'Ana',
        email: 'ana@example.com',
        senha: 'senha12345',
      ),
    ).thenAnswer(
      (_) async => Usuario(
        id: 'abc-123',
        nome: 'Ana',
        email: 'ana@example.com',
        criadoEm: DateTime.now(),
      ),
    );
    when(
      () => authApi.login(email: 'ana@example.com', senha: 'senha12345'),
    ).thenAnswer(
      (_) async => TokenAcesso(
        accessToken: 'jwt-abc',
        expiraEm: DateTime.now().add(const Duration(minutes: 15)),
      ),
    );

    final sucesso = await controller.submit(
      nome: 'Ana',
      email: 'ana@example.com',
      senha: 'senha12345',
    );

    expect(sucesso, isTrue);
    expect(controller.state.errorMessage, isNull);
    expect(sessionController.status, SessionStatus.authenticated);
    verify(
      () => authApi.cadastrar(
        nome: 'Ana',
        email: 'ana@example.com',
        senha: 'senha12345',
      ),
    ).called(1);
    verify(
      () => authApi.login(email: 'ana@example.com', senha: 'senha12345'),
    ).called(1);
  });

  test('submitComEmailJaCadastradoDeveExporMensagemDeErroSemLogar', () async {
    when(
      () => authApi.cadastrar(
        nome: 'Ana',
        email: 'ana@example.com',
        senha: 'senha12345',
      ),
    ).thenThrow(const ValidationException('E-mail já cadastrado.'));

    final sucesso = await controller.submit(
      nome: 'Ana',
      email: 'ana@example.com',
      senha: 'senha12345',
    );

    expect(sucesso, isFalse);
    expect(controller.state.errorMessage, 'E-mail já cadastrado.');
    verifyNever(
      () => authApi.login(
        email: any(named: 'email'),
        senha: any(named: 'senha'),
      ),
    );
  });
}
