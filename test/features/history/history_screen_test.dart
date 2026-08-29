import 'package:divergia_app/core/network/api_exception.dart';
import 'package:divergia_app/core/theme/app_theme.dart';
import 'package:divergia_app/features/history/data/historico_api.dart';
import 'package:divergia_app/features/history/data/models/analise_resumo.dart';
import 'package:divergia_app/features/history/presentation/history_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mocktail/mocktail.dart';

class _MockHistoricoApi extends Mock implements HistoricoApi {}

AnaliseResumo _item(String id, {String preview = 'preview'}) => AnaliseResumo(
  id: id,
  criadoEm: DateTime.now(),
  textoRetido: true,
  pontuacaoIntensidade: 50,
  tipoDesvioPrincipal: 'SENTIDO',
  textoPreview: preview,
);

void main() {
  late _MockHistoricoApi api;

  setUp(() {
    api = _MockHistoricoApi();
  });

  Widget buildApp() {
    final router = GoRouter(
      initialLocation: '/historico',
      routes: [
        GoRoute(
          path: '/historico',
          builder: (context, state) => const HistoryScreen(),
        ),
        GoRoute(
          path: '/historico/tendencia',
          builder: (context, state) => const Text('tela de tendência'),
        ),
        GoRoute(
          path: '/historico/:id',
          builder: (context, state) =>
              Text('detalhe ${state.pathParameters['id']}'),
        ),
      ],
    );
    return ProviderScope(
      overrides: [historicoApiProvider.overrideWithValue(api)],
      child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    );
  }

  testWidgets('deveMostrarOsCardsDepoisDeCarregar', (tester) async {
    when(() => api.listar()).thenAnswer(
      (_) async => [
        _item('1', preview: 'a nova versão da API otimiza requisições'),
        _item('2', preview: 'artigo de opinião econômica'),
      ],
    );

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.textContaining('a nova versão da API'), findsOneWidget);
    expect(find.textContaining('artigo de opinião'), findsOneWidget);
  });

  testWidgets('deveMostrarEstadoVazioQuandoNaoHaAnalises', (tester) async {
    when(() => api.listar()).thenAnswer((_) async => []);

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.textContaining('Nenhuma análise ainda'), findsOneWidget);
  });

  testWidgets('deveMostrarErroComBotaoDeTentarNovamente', (tester) async {
    when(() => api.listar()).thenThrow(const NetworkException());

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('Tentar novamente'), findsOneWidget);
  });

  testWidgets('deveFiltrarAListaAoDigitarNaBusca', (tester) async {
    when(() => api.listar()).thenAnswer(
      (_) async => [
        _item('1', preview: 'a nova versão da API'),
        _item('2', preview: 'artigo de opinião econômica'),
      ],
    );

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'API');
    await tester.pumpAndSettle();

    expect(find.textContaining('a nova versão da API'), findsOneWidget);
    expect(find.textContaining('artigo de opinião'), findsNothing);
  });

  testWidgets('deveNavegarParaODetalheAoTocarNoCard', (tester) async {
    when(() => api.listar()).thenAnswer((_) async => [_item('abc-123')]);

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Ver detalhes'));
    await tester.pumpAndSettle();

    expect(find.text('detalhe abc-123'), findsOneWidget);
  });

  testWidgets('deveNavegarParaOPainelDeTendenciaAoTocarNoIcone', (
    tester,
  ) async {
    when(() => api.listar()).thenAnswer((_) async => []);

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(LucideIcons.trendingUp));
    await tester.pumpAndSettle();

    expect(find.text('tela de tendência'), findsOneWidget);
  });
}
