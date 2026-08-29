import 'package:divergia_app/core/network/api_exception.dart';
import 'package:divergia_app/features/history/data/historico_api.dart';
import 'package:divergia_app/features/history/data/models/analise_resumo.dart';
import 'package:divergia_app/features/history/presentation/historico_controller.dart';
import 'package:flutter_test/flutter_test.dart';
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

  test('deveCarregarAListaComSucessoAoConstruir', () async {
    when(() => api.listar()).thenAnswer((_) async => [_item('1'), _item('2')]);

    final controller = HistoricoController(api);
    await Future<void>.delayed(Duration.zero);

    expect(controller.state.loading, isFalse);
    expect(controller.state.itens, hasLength(2));
    expect(controller.state.errorMessage, isNull);
  });

  test('deveExporMensagemDeErroQuandoFalhaAoCarregar', () async {
    when(() => api.listar()).thenThrow(const NetworkException());

    final controller = HistoricoController(api);
    await Future<void>.delayed(Duration.zero);

    expect(controller.state.loading, isFalse);
    expect(controller.state.errorMessage, isNotNull);
  });

  test('buscarDeveFiltrarPeloTextoPreviewSemBaterDeNovoNaApi', () async {
    when(() => api.listar()).thenAnswer(
      (_) async => [
        _item('1', preview: 'a nova versão da API'),
        _item('2', preview: 'artigo de opinião'),
      ],
    );
    final controller = HistoricoController(api);
    await Future<void>.delayed(Duration.zero);

    controller.buscar('API');

    expect(controller.state.itensFiltrados, hasLength(1));
    expect(controller.state.itensFiltrados.first.id, '1');
    verify(() => api.listar()).called(1);
  });

  test('carregarMaisDeveRevelarMaisItensDaListaJaBuscada', () async {
    final itens = List.generate(15, (i) => _item('$i'));
    when(() => api.listar()).thenAnswer((_) async => itens);

    final controller = HistoricoController(api);
    await Future<void>.delayed(Duration.zero);

    expect(controller.state.itensPaginados, hasLength(10));
    expect(controller.state.temMaisParaCarregar, isTrue);

    controller.carregarMais();

    expect(controller.state.itensPaginados, hasLength(15));
    expect(controller.state.temMaisParaCarregar, isFalse);
  });

  test('carregarMaisNaoDeveFazerNadaQuandoJaMostraTudo', () async {
    when(() => api.listar()).thenAnswer((_) async => [_item('1')]);
    final controller = HistoricoController(api);
    await Future<void>.delayed(Duration.zero);

    controller.carregarMais();

    expect(controller.state.quantidadeVisivel, 10);
  });
}
