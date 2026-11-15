import 'package:divergia_app/core/theme/app_theme.dart';
import 'package:divergia_app/features/dev/data/dev_api.dart';
import 'package:divergia_app/features/dev/data/models/estatisticas_globais.dart';
import 'package:divergia_app/features/dev/presentation/dev_estatisticas_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockDevApi extends Mock implements DevApi {}

EstatisticasGlobais _estatisticas({
  required int total,
  int hoje = 0,
  int derivas = 9,
}) {
  final hojeData = DateTime(2026, 11, 15);
  return EstatisticasGlobais(
    totalAnalises: total,
    totalDerivas: derivas,
    derivasPorTipo: const {'SENTIDO': 5, 'POSICAO': 3, 'INTENSIDADE': 1},
    serieDiaria: [
      for (var i = 6; i >= 0; i--)
        PontoDiario(
          dia: hojeData.subtract(Duration(days: i)),
          analises: i == 0 ? hoje : 1,
          derivasPorTipo: const {'SENTIDO': 1, 'POSICAO': 0, 'INTENSIDADE': 0},
          totalDerivas: 1,
        ),
    ],
    geradoEm: DateTime.utc(2026, 11, 15, 18, 30, 5),
  );
}

void main() {
  late _MockDevApi api;

  setUp(() => api = _MockDevApi());

  Future<void> abrir(WidgetTester tester) async {
    // Largura folgada: a fonte de teste é mais larga que a real e estoura Rows que cabem no aparelho.
    await tester.binding.setSurfaceSize(const Size(800, 1800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [devApiProvider.overrideWithValue(api)],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const DevEstatisticasScreen(),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump(const Duration(seconds: 2));
  }

  String texto(WidgetTester tester, String chave) =>
      tester.widget<Text>(find.byKey(Key(chave))).data!;

  testWidgets('mostraTotalDivergenciasEPeriodos', (tester) async {
    when(
      () => api.estatisticas(dias: any(named: 'dias')),
    ).thenAnswer((_) async => _estatisticas(total: 42, hoje: 4));

    await abrir(tester);

    expect(find.text('Painel de desenvolvedor'), findsOneWidget);
    expect(texto(tester, 'total-analises'), '42');
    expect(texto(tester, 'analises-hoje'), '4');
    expect(texto(tester, 'total-derivas'), '9');
    expect(find.textContaining('Ao vivo'), findsNothing);
    expect(find.textContaining('apagaram'), findsNothing);
    expect(find.text('Desvio de Sentido'), findsOneWidget);
    for (final periodo in [7, 30, 90]) {
      expect(find.byKey(Key('periodo-$periodo')), findsOneWidget);
    }
  });

  testWidgets('mediaExataApareceComoInteiroESemDecimalDesnecessario', (
    tester,
  ) async {
    when(
      () => api.estatisticas(dias: any(named: 'dias')),
    ).thenAnswer((_) async => _estatisticas(total: 3, derivas: 6));

    await abrir(tester);

    expect(texto(tester, 'media-por-analise'), '2');
  });

  testWidgets('mediaQuebradaMostraUmaCasaDecimalComVirgula', (tester) async {
    when(
      () => api.estatisticas(dias: any(named: 'dias')),
    ).thenAnswer((_) async => _estatisticas(total: 4, derivas: 6));

    await abrir(tester);

    expect(texto(tester, 'media-por-analise'), '1,5');
  });

  testWidgets('escolherOutroPeriodoPedeOsDadosDaNovaJanela', (tester) async {
    when(
      () => api.estatisticas(dias: any(named: 'dias')),
    ).thenAnswer((_) async => _estatisticas(total: 42));

    await abrir(tester);
    await tester.tap(find.byKey(const Key('periodo-90')));
    await tester.pump(const Duration(milliseconds: 50));

    verify(() => api.estatisticas(dias: 90)).called(greaterThanOrEqualTo(1));
  });
}
