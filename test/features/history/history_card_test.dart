import 'package:divergia_app/features/history/data/models/analise_resumo.dart';
import 'package:divergia_app/features/history/presentation/widgets/history_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('deveMostrarPontuacaoRotuloEPreviewQuandoHaTrechos', (tester) async {
    final analise = AnaliseResumo(
      id: '1',
      criadoEm: DateTime.now(),
      textoRetido: true,
      pontuacaoIntensidade: 72,
      tipoDesvioPrincipal: 'SENTIDO',
      textoPreview: 'um trecho de exemplo',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: HistoryCard(analise: analise, onTap: () {})),
      ),
    );

    expect(find.text('72 pts'), findsOneWidget);
    expect(find.text('Desvio de Sentido'), findsOneWidget);
    expect(find.text('um trecho de exemplo'), findsOneWidget);
    expect(find.text('Divergência Analisada'), findsOneWidget);
  });

  testWidgets('naoDeveMostrarBadgeDePontuacaoQuandoNaoHaTrechos', (tester) async {
    final analise = AnaliseResumo(
      id: '1',
      criadoEm: DateTime.now(),
      textoRetido: false,
      pontuacaoIntensidade: null,
      tipoDesvioPrincipal: null,
      textoPreview: null,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: HistoryCard(analise: analise, onTap: () {})),
      ),
    );

    expect(find.text('72 pts'), findsNothing);
    expect(find.textContaining('pts'), findsNothing);
    expect(find.text('Sem detalhes salvos'), findsOneWidget);
  });

  testWidgets('deveChamarOnTapAoTocarNoCard', (tester) async {
    var tocou = false;
    final analise = AnaliseResumo(
      id: '1',
      criadoEm: DateTime.now(),
      textoRetido: true,
      pontuacaoIntensidade: 50,
      tipoDesvioPrincipal: 'POSICAO',
      textoPreview: 'preview',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HistoryCard(analise: analise, onTap: () => tocou = true),
        ),
      ),
    );

    await tester.tap(find.byType(HistoryCard));
    await tester.pump();

    expect(tocou, isTrue);
  });
}
