import 'package:divergia_app/core/theme/app_theme.dart';
import 'package:divergia_app/features/profile/presentation/privacy_policy_screen.dart';
import 'package:divergia_app/features/profile/presentation/terms_of_service_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

void main() {
  Widget buildApp(Widget tela) {
    final router = GoRouter(
      initialLocation: '/historico',
      routes: [
        GoRoute(
          path: '/historico',
          builder: (context, state) => const Text('tela de historico'),
        ),
        GoRoute(path: '/documento', builder: (context, state) => tela),
      ],
    );
    return MaterialApp.router(theme: AppTheme.light, routerConfig: router);
  }

  testWidgets('TermsOfServiceScreen deve mostrar título e seções', (
    tester,
  ) async {
    await tester.pumpWidget(buildApp(const TermsOfServiceScreen()));
    final router = GoRouter.of(tester.element(find.text('tela de historico')));
    router.push('/documento');
    await tester.pumpAndSettle();

    expect(find.text('Termos de Serviço'), findsOneWidget);
    expect(find.text('1. Sobre o serviço'), findsOneWidget);
  });

  testWidgets(
    'TermsOfServiceScreen deve voltar pra tela anterior ao tocar no botão de voltar',
    (tester) async {
      await tester.pumpWidget(buildApp(const TermsOfServiceScreen()));
      final router = GoRouter.of(
        tester.element(find.text('tela de historico')),
      );
      router.push('/documento');
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(LucideIcons.chevronLeft));
      await tester.pumpAndSettle();

      expect(find.text('tela de historico'), findsOneWidget);
    },
  );

  testWidgets('PrivacyPolicyScreen deve mostrar título e seções', (
    tester,
  ) async {
    await tester.pumpWidget(buildApp(const PrivacyPolicyScreen()));
    final router = GoRouter.of(tester.element(find.text('tela de historico')));
    router.push('/documento');
    await tester.pumpAndSettle();

    expect(find.text('Política de Privacidade'), findsOneWidget);
    expect(find.text('1. Quais dados coletamos'), findsOneWidget);
  });
}
