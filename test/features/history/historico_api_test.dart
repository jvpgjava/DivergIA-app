import 'package:dio/dio.dart';
import 'package:divergia_app/core/network/api_client.dart';
import 'package:divergia_app/features/history/data/historico_api.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockApiClient extends Mock implements ApiClient {}

Response<T> _resposta<T>(T data) {
  return Response<T>(requestOptions: RequestOptions(path: '/qualquer'), data: data, statusCode: 200);
}

void main() {
  late _MockApiClient client;
  late HistoricoApi historicoApi;

  setUp(() {
    client = _MockApiClient();
    historicoApi = HistoricoApi(client);
  });

  test('listarDeveMapearCadaItemDaListaDoBackend', () async {
    when(() => client.get<List<dynamic>>('/api/historico')).thenAnswer(
      (_) async => _resposta([
        {
          'id': 'abc-123',
          'criadoEm': '2026-08-20T10:00:00.000Z',
          'textoRetido': true,
          'pontuacaoIntensidade': 72,
          'tipoDesvioPrincipal': 'SENTIDO',
          'textoPreview': 'um trecho de exemplo',
        },
        {
          'id': 'def-456',
          'criadoEm': '2026-08-19T10:00:00.000Z',
          'textoRetido': false,
          'pontuacaoIntensidade': null,
          'tipoDesvioPrincipal': null,
          'textoPreview': null,
        },
      ]),
    );

    final itens = await historicoApi.listar();

    expect(itens, hasLength(2));
    expect(itens[0].id, 'abc-123');
    expect(itens[0].pontuacaoIntensidade, 72);
    expect(itens[0].tipoDesvioPrincipal, 'SENTIDO');
    expect(itens[1].textoRetido, isFalse);
    expect(itens[1].pontuacaoIntensidade, isNull);
    expect(itens[1].textoPreview, isNull);
  });

  test('buscarDeveMapearOResultadoComSeusTrechos', () async {
    when(() => client.get<Map<String, dynamic>>('/api/historico/abc-123')).thenAnswer(
      (_) async => _resposta({
        'analiseId': 'abc-123',
        'criadoEm': '2026-08-20T10:00:00.000Z',
        'trechos': [
          {
            'id': 'trecho-1',
            'tipoDesvio': 'SENTIDO',
            'trechoOriginal': 'original',
            'trechoEditado': 'editado',
            'explicacao': 'explicação',
            'intensidade': 0.72,
          },
        ],
      }),
    );

    final resultado = await historicoApi.buscar('abc-123');

    expect(resultado.analiseId, 'abc-123');
    expect(resultado.trechos, hasLength(1));
    expect(resultado.trechos.first.intensidade, 0.72);
    expect(resultado.trechos.first.tipoDesvio, 'SENTIDO');
  });
}
