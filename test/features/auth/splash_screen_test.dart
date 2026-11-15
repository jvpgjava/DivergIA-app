import 'package:divergia_app/core/storage/secure_token_storage.dart';
import 'package:divergia_app/core/theme/app_color_tokens.dart';
import 'package:divergia_app/core/theme/app_theme.dart';
import 'package:divergia_app/features/auth/presentation/session_controller.dart';
import 'package:divergia_app/features/auth/presentation/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _SessaoFalsa extends SessionController {
  _SessaoFalsa() : super(SecureTokenStorage()) {
    status = SessionStatus.checking;
  }

  @override
  Future<void> checkSession() async {}
}

void main() {
  Future<void> abrir(WidgetTester tester, ThemeMode modo) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sessionControllerProvider.overrideWith((ref) => _SessaoFalsa()),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: modo,
          home: const SplashScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  String arquivoDaLogo(WidgetTester tester) {
    final imagem = tester.widget<Image>(find.byKey(const Key('splash-logo')));
    return (imagem.image as AssetImage).assetName;
  }

  testWidgets('temaClaroMostraSoALogoClaraSobreFundoBranco', (tester) async {
    await abrir(tester, ThemeMode.light);

    expect(find.byType(Image), findsOneWidget);
    expect(arquivoDaLogo(tester), 'assets/icon/divergia-icon-light.png');
    expect(
      tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor,
      const Color(0xFFFFFFFF),
    );
  });

  testWidgets('temaEscuroMostraSoALogoEscura', (tester) async {
    await abrir(tester, ThemeMode.dark);

    expect(find.byType(Image), findsOneWidget);
    expect(arquivoDaLogo(tester), 'assets/icon/divergia-icon-dark.png');
    expect(
      tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor,
      AppColorTokens.dark.background,
    );
  });

  testWidgets('fundoDaSplashEhLisoParaCombinarComASplashDoSistema', (
    tester,
  ) async {
    await abrir(tester, ThemeMode.light);

    final decoracoes = tester
        .widgetList<DecoratedBox>(find.byType(DecoratedBox))
        .where((d) => d.decoration is BoxDecoration)
        .map((d) => (d.decoration as BoxDecoration).gradient);
    expect(decoracoes.whereType<Gradient>(), isEmpty);
  });
}
