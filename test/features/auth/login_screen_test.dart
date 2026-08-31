import 'package:divergia_app/core/network/api_exception.dart';
import 'package:divergia_app/core/storage/secure_token_storage.dart';
import 'package:divergia_app/core/theme/app_theme.dart';
import 'package:divergia_app/features/auth/data/auth_api.dart';
import 'package:divergia_app/features/auth/presentation/login_screen.dart';
import 'package:divergia_app/features/auth/presentation/session_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
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

  setUp(() {
    FlutterSecureStoragePlatform.instance = _FakeSecureStoragePlatform();
    authApi = _MockAuthApi();
  });

  Widget buildApp() {
    final router = GoRouter(
      initialLocation: '/login',
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/signup',
          builder: (context, state) => const Text('tela de cadastro'),
        ),
        GoRoute(
          path: '/esqueci-senha',
          builder: (context, state) => const Text('tela de esqueci senha'),
        ),
      ],
    );
    return ProviderScope(
      overrides: [
        authApiProvider.overrideWithValue(authApi),
        // Sem isso, o Timer da espera mínima de splash (ver
        // `SessionController.duracaoMinimaSplash`) fica pendente no fim do
        // teste — nenhum destes testes envolve a splash de verdade.
        sessionControllerProvider.overrideWith(
          (ref) => SessionController(
            ref.watch(secureTokenStorageProvider),
            duracaoMinimaSplash: Duration.zero,
          ),
        ),
      ],
      child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    );
  }

  testWidgets('deveMostrarErroDeValidacaoQuandoCamposEstaoVazios', (
    tester,
  ) async {
    await tester.pumpWidget(buildApp());

    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();

    expect(find.text('Informe seu e-mail'), findsOneWidget);
    expect(find.text('Informe sua senha'), findsOneWidget);
    verifyNever(
      () => authApi.login(
        email: any(named: 'email'),
        senha: any(named: 'senha'),
      ),
    );
  });

  testWidgets('deveMostrarMensagemDeErroQuandoLoginFalha', (tester) async {
    when(
      () => authApi.login(email: 'ana@example.com', senha: 'senhaerrada'),
    ).thenThrow(const UnauthorizedException('E-mail ou senha inválidos.'));

    await tester.pumpWidget(buildApp());
    await tester.enterText(find.byType(TextFormField).first, 'ana@example.com');
    await tester.enterText(find.byType(TextFormField).last, 'senhaerrada');
    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();

    expect(find.text('E-mail ou senha inválidos.'), findsOneWidget);
  });

  testWidgets('deveNavegarParaCriarContaAoTocarNoLink', (tester) async {
    await tester.pumpWidget(buildApp());

    await tester.tap(find.text('Criar conta'));
    await tester.pumpAndSettle();

    expect(find.text('tela de cadastro'), findsOneWidget);
  });

  testWidgets('deveNavegarParaEsqueciSenhaAoTocarNoLink', (tester) async {
    await tester.pumpWidget(buildApp());

    await tester.tap(find.text('Esqueci minha senha'));
    await tester.pumpAndSettle();

    expect(find.text('tela de esqueci senha'), findsOneWidget);
  });

  testWidgets('deveAvisarQueLoginSocialNaoEstaDisponivel', (tester) async {
    await tester.pumpWidget(buildApp());

    await tester.tap(find.text('Google'));
    await tester.pump();

    expect(find.text('Login social ainda não disponível.'), findsOneWidget);
    verifyNever(
      () => authApi.login(
        email: any(named: 'email'),
        senha: any(named: 'senha'),
      ),
    );
  });
}
