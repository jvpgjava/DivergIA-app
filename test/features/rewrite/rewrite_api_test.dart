import 'package:dio/dio.dart';
import 'package:divergia_app/core/network/api_client.dart';
import 'package:divergia_app/features/rewrite/data/rewrite_api.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockApiClient extends Mock implements ApiClient {}

void main() {
  late _MockApiClient client;
  late RewriteApi api;

  setUp(() {
    client = _MockApiClient();
    api = RewriteApi(client);
  });

  test('sugerirDeveChamarOEndpointCorretoEDevolverAsTresSugestoes', () async {
    when(
      () => client.post<Map<String, dynamic>>(
        '/api/analises/trechos/trecho-1/sugestao-reescrita',
      ),
    ).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(
          path: '/api/analises/trechos/trecho-1/sugestao-reescrita',
        ),
        statusCode: 200,
        data: {
          'sugestoes': ['opção 1', 'opção 2', 'opção 3'],
        },
      ),
    );

    final sugestoes = await api.sugerir('trecho-1');

    expect(sugestoes, ['opção 1', 'opção 2', 'opção 3']);
    verify(
      () => client.post<Map<String, dynamic>>(
        '/api/analises/trechos/trecho-1/sugestao-reescrita',
      ),
    ).called(1);
  });

  test('aceitarDeveChamarOPutComOTextoEscolhido', () async {
    when(
      () => client.put<void>(
        '/api/analises/trechos/trecho-1/sugestao-reescrita',
        data: {'texto': 'opção 2'},
      ),
    ).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(
          path: '/api/analises/trechos/trecho-1/sugestao-reescrita',
        ),
        statusCode: 204,
      ),
    );

    await api.aceitar('trecho-1', 'opção 2');

    verify(
      () => client.put<void>(
        '/api/analises/trechos/trecho-1/sugestao-reescrita',
        data: {'texto': 'opção 2'},
      ),
    ).called(1);
  });
}
