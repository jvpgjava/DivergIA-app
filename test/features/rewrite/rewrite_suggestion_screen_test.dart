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

  const tresSugestoes = ['opção um', 'opção dois', 'opção três'];

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
    'deveMostrarOTrechoOriginalEAsTresOpcoesComAPrimeiraSelecionada',
    (tester) async {
      when(
        () => api.sugerir('trecho-1'),
      ).thenAnswer((_) async => tresSugestoes);

      await abrirTelaDeReescrita(tester);

      expect(
        find.textContaining('eliminando totalmente a necessidade de polling'),
        findsOneWidget,
      );
      expect(find.text('opção um'), findsOneWidget);
      expect(find.text('opção dois'), findsOneWidget);
      expect(find.text('opção três'), findsOneWidget);
      expect(find.textContaining('a explicação do desvio'), findsOneWidget);
      expect(find.byIcon(Icons.radio_button_checked), findsOneWidget);
    },
  );

  testWidgets('deveMostrarErroComBotaoDeTentarNovamenteQuandoAChamadaFalha', (
    tester,
  ) async {
    when(() => api.sugerir('trecho-1')).thenThrow(const NetworkException());

    await abrirTelaDeReescrita(tester);

    expect(find.text('Tentar novamente'), findsOneWidget);
  });

  testWidgets('devePermitirTrocarASugestaoSelecionadaAoTocarNaOpcao', (
    tester,
  ) async {
    when(
      () => api.sugerir('trecho-1'),
    ).thenAnswer((_) async => tresSugestoes);

    await abrirTelaDeReescrita(tester);
    await tester.tap(find.text('opção dois'));
    await tester.pump();

    expect(find.byIcon(Icons.radio_button_checked), findsOneWidget);
  });

  testWidgets(
    'deveMostrarPopupDeGerarMaisOpcoesAoTocarEmDescartarESairAoConfirmar',
    (tester) async {
      when(
        () => api.sugerir('trecho-1'),
      ).thenAnswer((_) async => tresSugestoes);

      await abrirTelaDeReescrita(tester);

      await tester.tap(find.text('Descartar'));
      await tester.pumpAndSettle();

      expect(find.text('Gerar mais opções'), findsOneWidget);

      await tester.tap(find.text('Sair'));
      await tester.pumpAndSettle();

      expect(find.text('abrir reescrita'), findsOneWidget);
    },
  );

  testWidgets(
    'deveGerarNovasOpcoesAoConfirmarNoPopupDeDescartar',
    (tester) async {
      when(
        () => api.sugerir('trecho-1'),
      ).thenAnswer((_) async => tresSugestoes);

      await abrirTelaDeReescrita(tester);

      await tester.tap(find.text('Descartar'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Gerar mais opções'));
      await tester.pumpAndSettle();

      verify(() => api.sugerir('trecho-1')).called(2);
      expect(find.text('opção um'), findsOneWidget);
    },
  );

  testWidgets(
    'deveAceitarASugestaoSelecionadaEVoltarParaATelaAnteriorComTrue',
    (tester) async {
      when(
        () => api.sugerir('trecho-1'),
      ).thenAnswer((_) async => tresSugestoes);
      when(
        () => api.aceitar('trecho-1', 'opção dois'),
      ).thenAnswer((_) async {});

      await abrirTelaDeReescrita(tester);
      await tester.tap(find.text('opção dois'));
      await tester.pump();

      await tester.tap(find.text('Aceitar sugestão'));
      await tester.pumpAndSettle();

      verify(() => api.aceitar('trecho-1', 'opção dois')).called(1);
      expect(find.text('abrir reescrita'), findsOneWidget);
    },
  );
}
