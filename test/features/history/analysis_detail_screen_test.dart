import 'package:divergia_app/core/network/api_exception.dart';
import 'package:divergia_app/features/analysis/data/models/resultado_analise.dart';
import 'package:divergia_app/features/analysis/data/models/trecho_deriva.dart';
import 'package:divergia_app/features/history/data/historico_api.dart';
import 'package:divergia_app/features/history/presentation/analysis_detail_screen.dart';
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
      child: const MaterialApp(
        home: AnalysisDetailScreen(analiseId: 'abc-123'),
      ),
    );
  }

  testWidgets('deveMostrarOsTrechosDaAnaliseAoCarregarComSucesso', (
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
            intensidade: 0.8,
          ),
        ],
      ),
    );

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.textContaining('Desvio de Sentido'), findsOneWidget);
    expect(find.textContaining('texto original'), findsOneWidget);
    expect(find.textContaining('a explicação do desvio'), findsOneWidget);
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
