import 'package:divergia_app/core/network/api_exception.dart';
import 'package:divergia_app/core/theme/app_theme.dart';
import 'package:divergia_app/features/history/data/historico_api.dart';
import 'package:divergia_app/features/history/data/models/painel_tendencia.dart';
import 'package:divergia_app/features/history/data/models/ponto_tendencia.dart';
import 'package:divergia_app/features/history/presentation/tendencia_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

class _MockHistoricoApi extends Mock implements HistoricoApi {}

void main() {
  late _MockHistoricoApi api;

  setUp(() {
    api = _MockHistoricoApi();
  });

  Widget buildApp() {
    final router = GoRouter(
      initialLocation: '/anterior',
      routes: [
        GoRoute(
          path: '/anterior',
          builder: (context, state) => Scaffold(
            body: TextButton(
              onPressed: () => context.push('/tendencia'),
              child: const Text('abrir tendencia'),
            ),
          ),
        ),
        GoRoute(
          path: '/tendencia',
          builder: (context, state) => const TendenciaScreen(),
        ),
      ],
    );
    return ProviderScope(
      overrides: [historicoApiProvider.overrideWithValue(api)],
      child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    );
  }

  Future<void> abrirTela(WidgetTester tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('abrir tendencia'));
    await tester.pumpAndSettle();
  }

  testWidgets('deveMostrarOsCardsDeResumoEAEvolucaoMensal', (tester) async {
    when(() => api.tendencia()).thenAnswer(
      (_) async => const PainelTendencia(
        totalAnalises: 5,
        totalDerivas: 8,
        intensidadeMedia: 0.42,
        derivasPorTipo: {'SENTIDO': 6, 'POSICAO': 1, 'INTENSIDADE': 1},
        evolucaoMensal: [
          PontoTendencia(
            mes: '2026-07',
            quantidadeAnalises: 2,
            quantidadeDerivas: 3,
            intensidadeMedia: 0.3,
          ),
          PontoTendencia(
            mes: '2026-08',
            quantidadeAnalises: 3,
            quantidadeDerivas: 5,
            intensidadeMedia: 0.5,
          ),
        ],
      ),
    );

    await abrirTela(tester);

    expect(find.text('5'), findsOneWidget);
    expect(find.text('8'), findsOneWidget);
    expect(find.text('42 pts'), findsOneWidget);
    expect(find.text('Intensidade média por mês'), findsOneWidget);
    expect(find.text('Divergências por tipo'), findsOneWidget);
    expect(find.text('Desvio de Sentido'), findsOneWidget);
    expect(find.text('Mudança de Posição'), findsOneWidget);
    expect(find.text('Alteração de Intensidade'), findsOneWidget);
  });

  testWidgets(
    'deveMostrarMensagemDeDadosInsuficientesComMenosDeDoisMeses',
    (tester) async {
      when(() => api.tendencia()).thenAnswer(
        (_) async => const PainelTendencia(
          totalAnalises: 1,
          totalDerivas: 1,
          intensidadeMedia: 0.3,
          derivasPorTipo: {'SENTIDO': 1},
          evolucaoMensal: [
            PontoTendencia(
              mes: '2026-08',
              quantidadeAnalises: 1,
              quantidadeDerivas: 1,
              intensidadeMedia: 0.3,
            ),
          ],
        ),
      );

      await abrirTela(tester);

      expect(
        find.textContaining('Ainda não há meses suficientes'),
        findsOneWidget,
      );
    },
  );

  testWidgets('deveMostrarEstadoVazioQuandoNaoHaAnalises', (tester) async {
    when(() => api.tendencia()).thenAnswer(
      (_) async => const PainelTendencia(
        totalAnalises: 0,
        totalDerivas: 0,
        intensidadeMedia: 0,
        derivasPorTipo: {},
        evolucaoMensal: [],
      ),
    );

    await abrirTela(tester);

    expect(
      find.textContaining('Ainda não há análises suficientes'),
      findsOneWidget,
    );
  });

  testWidgets('deveMostrarErroComBotaoDeTentarNovamenteQuandoAChamadaFalha', (
    tester,
  ) async {
    when(() => api.tendencia()).thenThrow(const NetworkException());

    await abrirTela(tester);

    expect(find.text('Tentar novamente'), findsOneWidget);
  });
}
