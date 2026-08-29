import 'package:divergia_app/core/router/app_router.dart';
import 'package:divergia_app/core/storage/secure_token_storage.dart';
import 'package:divergia_app/core/theme/app_colors.dart';
import 'package:divergia_app/core/theme/app_theme.dart';
import 'package:divergia_app/features/auth/data/auth_api.dart';
import 'package:divergia_app/features/auth/data/models/usuario.dart';
import 'package:divergia_app/features/auth/presentation/session_controller.dart';
import 'package:divergia_app/features/history/data/historico_api.dart';
import 'package:divergia_app/features/profile/data/consentimento_api.dart';
import 'package:divergia_app/features/profile/data/models/consentimento.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Nunca toca o `flutter_secure_storage` real (que exigiria mockar o
/// platform channel) — o status de sessão é setado direto pelo teste.
class _FakeSessionController extends SessionController {
  _FakeSessionController(SessionStatus initialStatus)
    : super(SecureTokenStorage()) {
    status = initialStatus;
  }

  @override
  Future<void> checkSession() async {}
}

class _MockHistoricoApi extends Mock implements HistoricoApi {}

class _MockAuthApi extends Mock implements AuthApi {}

class _MockConsentimentoApi extends Mock implements ConsentimentoApi {}

void main() {
  late GoRouter router;
  late _MockHistoricoApi historicoApi;
  late _MockAuthApi authApi;
  late _MockConsentimentoApi consentimentoApi;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    historicoApi = _MockHistoricoApi();
    when(() => historicoApi.listar()).thenAnswer((_) async => []);

    authApi = _MockAuthApi();
    when(() => authApi.me()).thenAnswer(
      (_) async => Usuario(
        id: 'usuario-1',
        nome: 'Ana Clara',
        email: 'ana@example.com',
        criadoEm: DateTime.now(),
      ),
    );

    consentimentoApi = _MockConsentimentoApi();
    when(() => consentimentoApi.obter()).thenAnswer(
      (_) async => Consentimento(
        manterHistorico: true,
        contribuirParaRag: false,
        concedidoEm: DateTime.now(),
      ),
    );
  });

  Widget buildApp(SessionStatus status) {
    final fakeSession = _FakeSessionController(status);
    router = buildAppRouter(fakeSession);
    return ProviderScope(
      overrides: [
        // Sem isso, qualquer provider que dependa de `sessionControllerProvider`
        // (como o `ProfileController`, pra fazer logout) criaria uma segunda
        // instância REAL de `SessionController`, que tentaria acessar o
        // `flutter_secure_storage` de verdade — sem handler de plataforma
        // configurado neste teste, trava o `pumpAndSettle` pra sempre.
        sessionControllerProvider.overrideWith((ref) => fakeSession),
        historicoApiProvider.overrideWithValue(historicoApi),
        authApiProvider.overrideWithValue(authApi),
        consentimentoApiProvider.overrideWithValue(consentimentoApi),
      ],
      child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    );
  }

  testWidgets('deveFicarNaSplashEnquantoVerificaASessaoETemaTerACorDoFigma', (
    tester,
  ) async {
    await tester.pumpWidget(buildApp(SessionStatus.checking));

    final logo = find.byKey(const Key('splash-logo'));
    expect(logo, findsOneWidget);
    expect(
      Theme.of(tester.element(logo)).colorScheme.primary,
      AppColors.primary,
    );
  });

  testWidgets('deveIrDaSplashParaLoginQuandoNaoHaSessao', (tester) async {
    await tester.pumpWidget(buildApp(SessionStatus.unauthenticated));
    await tester.pumpAndSettle();

    expect(find.text('Bem-vindo'), findsOneWidget);
  });

  testWidgets('deveIrDaSplashDiretoParaHistoricoQuandoJaHaSessao', (
    tester,
  ) async {
    await tester.pumpWidget(buildApp(SessionStatus.authenticated));
    await tester.pumpAndSettle();

    expect(find.text('Minhas análises'), findsOneWidget);
  });

  testWidgets('deveRedirecionarParaLoginAoTentarAbrirRotaProtegidaDeslogado', (
    tester,
  ) async {
    await tester.pumpWidget(buildApp(SessionStatus.unauthenticated));
    await tester.pumpAndSettle();

    router.go('/historico');
    await tester.pumpAndSettle();

    expect(find.text('Bem-vindo'), findsOneWidget);
  });

  testWidgets('deveRedirecionarParaHistoricoAoTentarAbrirLoginJaAutenticado', (
    tester,
  ) async {
    await tester.pumpWidget(buildApp(SessionStatus.authenticated));
    await tester.pumpAndSettle();

    router.go('/login');
    await tester.pumpAndSettle();

    expect(find.text('Minhas análises'), findsOneWidget);
  });

  testWidgets('deveNavegarDeLoginParaCriarConta', (tester) async {
    await tester.pumpWidget(buildApp(SessionStatus.unauthenticated));
    await tester.pumpAndSettle();

    router.go('/signup');
    await tester.pumpAndSettle();

    expect(find.text('Criar conta'), findsWidgets);
  });

  testWidgets('deveNavegarPelaBottomNavEntreHistoricoEPerfil', (tester) async {
    await tester.pumpWidget(buildApp(SessionStatus.authenticated));
    await tester.pumpAndSettle();

    expect(find.text('Minhas análises'), findsOneWidget);

    await tester.tap(find.text('Perfil'));
    await tester.pumpAndSettle();

    expect(find.text('Perfil'), findsWidgets);
  });

  testWidgets('deveAbrirNovaAnaliseAoTocarNoBotaoCentral', (tester) async {
    await tester.pumpWidget(buildApp(SessionStatus.authenticated));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(LucideIcons.plus));
    await tester.pumpAndSettle();

    expect(find.text('Nova análise'), findsOneWidget);
  });
}
