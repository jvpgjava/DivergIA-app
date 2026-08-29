import 'package:divergia_app/core/network/api_exception.dart';
import 'package:divergia_app/core/theme/app_theme.dart';
import 'package:divergia_app/features/analysis/data/models/trecho_deriva.dart';
import 'package:divergia_app/features/rewrite/data/rewrite_api.dart';
import 'package:divergia_app/features/rewrite/presentation/rewrite_suggestion_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

class _MockRewriteApi extends Mock implements RewriteApi {}

void main() {
  late _MockRewriteApi api;

  const trecho = TrechoDeriva(
    id: 'trecho-1',
    tipoDesvio: 'SENTIDO',
    trechoOriginal: 'eliminando totalmente a necessidade de polling',
    trechoEditado: 'reduzindo o polling',
    explicacao: 'a explicação do desvio',
    intensidade: 0.72,
  );

  setUp(() {
    api = _MockRewriteApi();
  });

  Widget buildApp() {
    final router = GoRouter(
      initialLocation: '/anterior',
      routes: [
        GoRoute(
          path: '/anterior',
          builder: (context, state) => Scaffold(
            body: TextButton(
              onPressed: () => context.push('/reescrita', extra: trecho),
              child: const Text('abrir reescrita'),
            ),
          ),
        ),
        GoRoute(
          path: '/reescrita',
          builder: (context, state) =>
              RewriteSuggestionScreen(trecho: state.extra as TrechoDeriva),
        ),
      ],
    );
    return ProviderScope(
      overrides: [rewriteApiProvider.overrideWithValue(api)],
      child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    );
  }

  Future<void> abrirTelaDeReescrita(WidgetTester tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('abrir reescrita'));
    await tester.pumpAndSettle();
  }

  testWidgets(
    'deveMostrarOTrechoOriginalEATextoDaSugestaoJaPreenchidoEEditavel',
    (tester) async {
      when(
        () => api.sugerir('trecho-1'),
      ).thenAnswer((_) async => 'texto reescrito fiel ao original');

      await abrirTelaDeReescrita(tester);

      expect(
        find.textContaining('eliminando totalmente a necessidade de polling'),
        findsOneWidget,
      );
      expect(find.text('texto reescrito fiel ao original'), findsOneWidget);
      expect(find.textContaining('a explicação do desvio'), findsOneWidget);

      await tester.enterText(
        find.widgetWithText(TextField, 'texto reescrito fiel ao original'),
        'texto editado pela pessoa',
      );
      await tester.pump();

      expect(find.text('texto editado pela pessoa'), findsOneWidget);
    },
  );

  testWidgets('deveMostrarErroComBotaoDeTentarNovamenteQuandoAChamadaFalha', (
    tester,
  ) async {
    when(() => api.sugerir('trecho-1')).thenThrow(const NetworkException());

    await abrirTelaDeReescrita(tester);

    expect(find.text('Tentar novamente'), findsOneWidget);
  });

  testWidgets('deveVoltarParaATelaAnteriorAoTocarEmDescartar', (tester) async {
    when(
      () => api.sugerir('trecho-1'),
    ).thenAnswer((_) async => 'texto reescrito fiel ao original');

    await abrirTelaDeReescrita(tester);

    await tester.tap(find.text('Descartar'));
    await tester.pumpAndSettle();

    expect(find.text('abrir reescrita'), findsOneWidget);
  });

  testWidgets('deveVoltarParaATelaAnteriorAoTocarEmAceitarSugestao', (
    tester,
  ) async {
    when(
      () => api.sugerir('trecho-1'),
    ).thenAnswer((_) async => 'texto reescrito fiel ao original');

    await abrirTelaDeReescrita(tester);

    await tester.tap(find.text('Aceitar sugestão'));
    await tester.pumpAndSettle();

    expect(find.text('abrir reescrita'), findsOneWidget);
  });
}
