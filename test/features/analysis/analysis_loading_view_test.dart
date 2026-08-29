import 'package:divergia_app/features/analysis/presentation/widgets/analysis_loading_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('deveMostrarOsTresPassosEOPercentualInicial', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: AnalysisLoadingView())),
    );

    expect(find.textContaining('%'), findsOneWidget);
    expect(find.text('Comparando textos estruturalmente'), findsOneWidget);
    expect(
      find.text('Consultando base de referência semântica'),
      findsOneWidget,
    );
    expect(find.text('Gerando relatório de divergências'), findsOneWidget);

    // não deixa timer pendente ao final do teste
    await tester.pump(const Duration(seconds: 10));
  });

  testWidgets('oPercentualDeveAvancarComOTempoSemUltrapassar92', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: AnalysisLoadingView())),
    );

    expect(find.text('4%'), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    expect(find.text('4%'), findsNothing);

    await tester.pump(const Duration(seconds: 30));
    expect(find.text('92%'), findsOneWidget);
  });
}
