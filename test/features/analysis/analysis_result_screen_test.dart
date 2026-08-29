import 'package:divergia_app/core/network/api_exception.dart';
import 'package:divergia_app/core/theme/app_theme.dart';
import 'package:divergia_app/features/analysis/data/models/resultado_analise.dart';
import 'package:divergia_app/features/analysis/data/models/trecho_deriva.dart';
import 'package:divergia_app/features/analysis/presentation/analysis_result_screen.dart';
import 'package:divergia_app/features/history/data/historico_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockHistoricoApi extends Mock implements HistoricoApi {}

void main() {
  late _MockHistoricoApi api;

  setUp(() {
    api = _MockHistoricoApi();
  });

  Widget buildApp() {
    return ProviderScope(
      overrides: [historicoApiProvider.overrideWithValue(api)],
      child: MaterialApp(
        theme: AppTheme.light,
        home: const AnalysisResultScreen(analiseId: 'abc-123'),
      ),
    );
  }

  testWidgets('deveMostrarOScoreCardEOsTrechosAoCarregarComSucesso', (
    tester,
  ) async {
    when(() => api.buscar('abc-123')).thenAnswer(
      (_) async => ResultadoAnalise(
        analiseId: 'abc-123',
        criadoEm: DateTime.now(),
        trechos: [
          const TrechoDeriva(
            id: 't1',
            tipoDesvio: 'SENTIDO',
            trechoOriginal: 'texto original',
            trechoEditado: 'texto editado',
            explicacao: 'a explicação do desvio',
            intensidade: 0.72,
          ),
        ],
      ),
    );

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('72'), findsOneWidget);
    expect(find.text('Desvio de Sentido Elevado'), findsOneWidget);
    expect(find.textContaining('Detectamos 1 divergência crítica'), findsOneWidget);
    expect(find.text('texto original'), findsOneWidget);
    expect(find.text('texto editado'), findsOneWidget);
    expect(find.textContaining('a explicação do desvio'), findsOneWidget);
    expect(find.text('Sugerir reescrita fiel'), findsOneWidget);
  });

  testWidgets(
    'deveMostrarMultiplosTrechosQuandoAAnaliseTemMaisDeUmaDivergencia',
    (tester) async {
      when(() => api.buscar('abc-123')).thenAnswer(
        (_) async => ResultadoAnalise(
          analiseId: 'abc-123',
          criadoEm: DateTime.now(),
          trechos: const [
            TrechoDeriva(
              id: 't1',
              tipoDesvio: 'SENTIDO',
              trechoOriginal: 'original 1',
              trechoEditado: 'editado 1',
              explicacao: 'explicação 1',
              intensidade: 0.72,
            ),
            TrechoDeriva(
              id: 't2',
              tipoDesvio: 'POSICAO',
              trechoOriginal: 'original 2',
              trechoEditado: 'editado 2',
              explicacao: 'explicação 2',
              intensidade: 0.3,
            ),
          ],
        ),
      );

      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      expect(find.textContaining('Detectamos 2 divergências'), findsOneWidget);
      expect(find.textContaining('original 1'), findsOneWidget);
      expect(find.textContaining('original 2'), findsOneWidget);
      expect(find.text('Sugerir reescrita fiel'), findsNWidgets(2));
    },
  );

  testWidgets('deveMostrarMensagemDeVazioQuandoNaoHaTrechos', (tester) async {
    when(() => api.buscar('abc-123')).thenAnswer(
      (_) async => ResultadoAnalise(
        analiseId: 'abc-123',
        criadoEm: DateTime.now(),
        trechos: const [],
      ),
    );

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Nenhuma divergência de sentido foi encontrada'),
      findsOneWidget,
    );
  });

  testWidgets('deveMostrarMensagemDeErroComBotaoDeTentarNovamente', (
    tester,
  ) async {
    when(() => api.buscar('abc-123')).thenThrow(const NotFoundException());

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('Tentar novamente'), findsOneWidget);
  });
}
