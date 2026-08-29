import 'package:divergia_app/core/network/api_exception.dart';
import 'package:divergia_app/core/theme/app_theme.dart';
import 'package:divergia_app/features/analysis/data/analise_api.dart';
import 'package:divergia_app/features/analysis/data/models/resultado_analise.dart';
import 'package:divergia_app/features/analysis/presentation/new_analysis_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

class _MockAnaliseApi extends Mock implements AnaliseApi {}

void main() {
  late _MockAnaliseApi api;

  setUp(() {
    api = _MockAnaliseApi();
  });

  Widget buildApp() {
    final router = GoRouter(
      initialLocation: '/nova-analise',
      routes: [
        GoRoute(
          path: '/nova-analise',
          builder: (context, state) => const NewAnalysisScreen(),
        ),
        GoRoute(
          path: '/historico/:id',
          builder: (context, state) =>
              Text('detalhe ${state.pathParameters['id']}'),
        ),
      ],
    );
    return ProviderScope(
      overrides: [analiseApiProvider.overrideWithValue(api)],
      child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    );
  }

  testWidgets('deveMostrarErrosDeValidacaoQuandoOsDoisCamposEstaoVazios', (
    tester,
  ) async {
    await tester.pumpWidget(buildApp());

    await tester.tap(find.text('Analisar textos'));
    await tester.pump();

    expect(find.text('Cole o texto ou anexe um arquivo'), findsNWidgets(2));
    verifyNever(
      () => api.analisar(
        textoOriginal: any(named: 'textoOriginal'),
        arquivoOriginal: any(named: 'arquivoOriginal'),
        textoEditado: any(named: 'textoEditado'),
        arquivoEditado: any(named: 'arquivoEditado'),
        manterHistorico: any(named: 'manterHistorico'),
      ),
    );
  });

  testWidgets(
    'deveAnalisarENavegarParaODetalheQuandoOsDoisCamposEstaoPreenchidos',
    (tester) async {
      when(
        () => api.analisar(
          textoOriginal: 'texto original',
          arquivoOriginal: null,
          textoEditado: 'texto editado',
          arquivoEditado: null,
          manterHistorico: true,
        ),
      ).thenAnswer(
        (_) async => ResultadoAnalise(
          analiseId: 'abc-123',
          criadoEm: DateTime.now(),
          trechos: const [],
        ),
      );

      await tester.pumpWidget(buildApp());

      final campos = find.byType(TextField);
      await tester.enterText(campos.at(0), 'texto original');
      await tester.enterText(campos.at(1), 'texto editado');

      await tester.tap(find.text('Analisar textos'));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('detalhe abc-123'), findsOneWidget);
    },
  );

  testWidgets('deveMostrarMensagemDeErroQuandoAAnaliseFalha', (tester) async {
    when(
      () => api.analisar(
        textoOriginal: 'texto original',
        arquivoOriginal: null,
        textoEditado: 'texto editado',
        arquivoEditado: null,
        manterHistorico: true,
      ),
    ).thenThrow(const NetworkException());

    await tester.pumpWidget(buildApp());

    final campos = find.byType(TextField);
    await tester.enterText(campos.at(0), 'texto original');
    await tester.enterText(campos.at(1), 'texto editado');

    await tester.tap(find.text('Analisar textos'));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Sem conexão com o servidor. Verifique sua internet e tente novamente.',
      ),
      findsOneWidget,
    );
  });
}
