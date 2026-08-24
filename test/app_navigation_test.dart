import 'package:divergia_app/core/router/app_router.dart';
import 'package:divergia_app/core/storage/secure_token_storage.dart';
import 'package:divergia_app/core/theme/app_colors.dart';
import 'package:divergia_app/core/theme/app_theme.dart';
import 'package:divergia_app/features/auth/presentation/session_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

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

void main() {
  late GoRouter router;

  Widget buildApp(SessionStatus status) {
    router = buildAppRouter(_FakeSessionController(status));
    return ProviderScope(
      child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    );
  }

  testWidgets('deveFicarNaSplashEnquantoVerificaASessaoETemaTerACorDoFigma', (
    tester,
  ) async {
    await tester.pumpWidget(buildApp(SessionStatus.checking));

    expect(find.text('DivergIA'), findsOneWidget);
    expect(
      Theme.of(tester.element(find.text('DivergIA'))).colorScheme.primary,
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

    expect(find.text('Histórico'), findsWidgets);
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

    expect(find.text('Histórico'), findsWidgets);
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

    expect(find.text('Histórico'), findsWidgets);

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
