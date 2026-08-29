import 'package:dio/dio.dart';
import 'package:divergia_app/core/network/api_client.dart';
import 'package:divergia_app/features/profile/data/consentimento_api.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockApiClient extends Mock implements ApiClient {}

Response<Map<String, dynamic>> _jsonResponse(Map<String, dynamic> data) {
  return Response(
    requestOptions: RequestOptions(path: '/qualquer'),
    data: data,
    statusCode: 200,
  );
}

void main() {
  late _MockApiClient client;
  late ConsentimentoApi api;

  setUp(() {
    client = _MockApiClient();
    api = ConsentimentoApi(client);
  });

  test('obterDeveChamarOEndpointCertoEMapearAResposta', () async {
    when(
      () => client.get<Map<String, dynamic>>('/api/consentimento'),
    ).thenAnswer(
      (_) async => _jsonResponse({
        'manterHistorico': true,
        'contribuirParaRag': false,
        'concedidoEm': '2026-08-20T10:00:00.000Z',
      }),
    );

    final consentimento = await api.obter();

    expect(consentimento.manterHistorico, isTrue);
    expect(consentimento.contribuirParaRag, isFalse);
  });

  test('atualizarDeveEnviarOCorpoCertoEMapearAResposta', () async {
    when(
      () => client.put<Map<String, dynamic>>(
        '/api/consentimento',
        data: {'manterHistorico': false, 'contribuirParaRag': true},
      ),
    ).thenAnswer(
      (_) async => _jsonResponse({
        'manterHistorico': false,
        'contribuirParaRag': true,
        'concedidoEm': '2026-08-20T10:00:00.000Z',
      }),
    );

    final consentimento = await api.atualizar(
      manterHistorico: false,
      contribuirParaRag: true,
    );

    expect(consentimento.manterHistorico, isFalse);
    expect(consentimento.contribuirParaRag, isTrue);
  });
}
