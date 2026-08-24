import 'package:divergia_app/core/router/app_router.dart';
import 'package:divergia_app/core/theme/app_colors.dart';
import 'package:divergia_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

void main() {
  late GoRouter router;

  setUp(() => router = buildAppRouter());

  Widget buildApp() {
    return ProviderScope(
      child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    );
  }

  testWidgets('deveAbrirNaSplashETemaTerACorDoFigmaAplicada', (tester) async {
    await tester.pumpWidget(buildApp());

    expect(find.text('DivergIA'), findsOneWidget);
    expect(
      Theme.of(tester.element(find.text('DivergIA'))).colorScheme.primary,
      AppColors.primary,
    );

    await tester.pumpAndSettle(const Duration(seconds: 1));
  });

  testWidgets('deveNavegarDaSplashParaLoginAutomaticamente', (tester) async {
    await tester.pumpWidget(buildApp());

    await tester.pumpAndSettle(const Duration(seconds: 1));

    expect(find.text('Login'), findsOneWidget);
  });

  testWidgets('deveNavegarDeLoginParaCriarConta', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle(const Duration(seconds: 1));

    router.go('/signup');
    await tester.pumpAndSettle();

    expect(find.text('Criar conta'), findsOneWidget);
  });

  testWidgets('deveNavegarPelaBottomNavEntreHistoricoEPerfil', (tester) async {
    await tester.pumpWidget(buildApp());
    router.go('/historico');
    await tester.pumpAndSettle();

    expect(find.text('Histórico'), findsWidgets);

    await tester.tap(find.text('Perfil'));
    await tester.pumpAndSettle();

    expect(find.text('Perfil'), findsWidgets);
  });

  testWidgets('deveAbrirNovaAnaliseAoTocarNoBotaoCentral', (tester) async {
    await tester.pumpWidget(buildApp());
    router.go('/historico');
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(LucideIcons.plus));
    await tester.pumpAndSettle();

    expect(find.text('Nova análise'), findsOneWidget);
  });
}
