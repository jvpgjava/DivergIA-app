import 'package:divergia_app/core/network/api_exception.dart';
import 'package:divergia_app/core/widgets/app_checkbox.dart';
import 'package:divergia_app/features/auth/data/auth_api.dart';
import 'package:divergia_app/features/auth/presentation/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthApi extends Mock implements AuthApi {}

void main() {
  late _MockAuthApi authApi;
  late GoRouter router;

  setUp(() {
    authApi = _MockAuthApi();
    router = GoRouter(
      initialLocation: '/login',
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const Text('tela de login'),
        ),
        GoRoute(
          path: '/signup',
          builder: (context, state) => const SignupScreen(),
        ),
      ],
    );
  });

  /// A tela de cadastro é mais alta que o viewport padrão de teste
  /// (800x600) e mais estreita que o normal de um app real (as duas
  /// diferenças aparecem na tela real também: use um viewport de celular
  /// pra não precisar rolar até os elementos antes de tocar neles). Começa
  /// em `/login` e empurra pra `/signup` só depois do primeiro pump — o
  /// `GoRouter` precisa estar anexado a um `Navigator` antes de aceitar um
  /// `push` de verdade (senão vira location inicial, sem stack pra `pop`).
  Future<void> pumpSignupScreen(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [authApiProvider.overrideWithValue(authApi)],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    router.push('/signup');
    await tester.pumpAndSettle();
  }

  Future<void> preencherFormulario(
    WidgetTester tester, {
    String senha = 'senha12345',
  }) async {
    final campos = find.byType(TextFormField);
    await tester.enterText(campos.at(0), 'Ana Clara');
    await tester.enterText(campos.at(1), 'ana@example.com');
    await tester.enterText(campos.at(2), senha);
    await tester.enterText(campos.at(3), senha);
  }

  testWidgets('deveMostrarErroDeValidacaoQuandoCamposEstaoVazios', (
    tester,
  ) async {
    await pumpSignupScreen(tester);

    await tester.tap(find.text('Criar conta').last);
    await tester.pumpAndSettle();

    expect(find.text('Informe seu nome'), findsOneWidget);
    expect(find.text('Informe seu e-mail'), findsOneWidget);
    expect(find.text('Informe uma senha'), findsOneWidget);
  });

  testWidgets('deveExigirAceiteDosTermosMesmoComFormularioValido', (
    tester,
  ) async {
    await pumpSignupScreen(tester);
    await preencherFormulario(tester);

    await tester.tap(find.text('Criar conta').last);
    await tester.pumpAndSettle();

    expect(
      find.text('É preciso aceitar os termos para continuar.'),
      findsOneWidget,
    );
    verifyNever(
      () => authApi.cadastrar(
        nome: any(named: 'nome'),
        email: any(named: 'email'),
        senha: any(named: 'senha'),
      ),
    );
  });

  testWidgets('deveAcusarSenhasDiferentesNaConfirmacao', (tester) async {
    await pumpSignupScreen(tester);
    final campos = find.byType(TextFormField);
    await tester.enterText(campos.at(0), 'Ana Clara');
    await tester.enterText(campos.at(1), 'ana@example.com');
    await tester.enterText(campos.at(2), 'senha12345');
    await tester.enterText(campos.at(3), 'outraSenha');

    await tester.tap(find.byType(AppCheckbox));
    await tester.tap(find.text('Criar conta').last);
    await tester.pumpAndSettle();

    expect(find.text('As senhas não coincidem'), findsOneWidget);
  });

  testWidgets('deveMostrarMensagemDeErroQuandoEmailJaCadastrado', (
    tester,
  ) async {
    when(
      () => authApi.cadastrar(
        nome: 'Ana Clara',
        email: 'ana@example.com',
        senha: 'senha12345',
      ),
    ).thenThrow(const ValidationException('E-mail já cadastrado.'));

    await pumpSignupScreen(tester);
    await preencherFormulario(tester);
    await tester.tap(find.byType(AppCheckbox));
    await tester.tap(find.text('Criar conta').last);
    await tester.pumpAndSettle();

    expect(find.text('E-mail já cadastrado.'), findsOneWidget);
  });

  testWidgets('deveVoltarParaLoginAoTocarNoLink', (tester) async {
    await pumpSignupScreen(tester);

    await tester.tap(find.text('Fazer login'));
    await tester.pumpAndSettle();

    expect(find.text('tela de login'), findsOneWidget);
  });
}
