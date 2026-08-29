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

  test('sugerirDeveChamarOEndpointCorretoEDevolverATextoDaSugestao', () async {
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
        data: {'sugestao': 'texto reescrito fiel ao original'},
      ),
    );

    final sugestao = await api.sugerir('trecho-1');

    expect(sugestao, 'texto reescrito fiel ao original');
    verify(
      () => client.post<Map<String, dynamic>>(
        '/api/analises/trechos/trecho-1/sugestao-reescrita',
      ),
    ).called(1);
  });
}
