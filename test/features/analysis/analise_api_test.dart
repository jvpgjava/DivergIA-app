import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:divergia_app/core/network/api_client.dart';
import 'package:divergia_app/features/analysis/data/analise_api.dart';
import 'package:divergia_app/features/analysis/data/models/arquivo_selecionado.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockApiClient extends Mock implements ApiClient {}

void main() {
  late _MockApiClient client;
  late AnaliseApi api;

  setUp(() {
    client = _MockApiClient();
    api = AnaliseApi(client);
    registerFallbackValue(FormData());
  });

  test('analisarDeveChamarOEndpointCorretoEMapearAResposta', () async {
    when(
      () => client.post<Map<String, dynamic>>(
        '/api/analises',
        data: any(named: 'data'),
      ),
    ).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(path: '/api/analises'),
        statusCode: 201,
        data: {
          'analiseId': 'abc-123',
          'criadoEm': '2026-08-20T10:00:00.000Z',
          'trechos': <dynamic>[],
        },
      ),
    );

    final resultado = await api.analisar(
      textoOriginal: 'original',
      textoEditado: 'editado',
      manterHistorico: true,
    );

    expect(resultado.analiseId, 'abc-123');
    verify(
      () => client.post<Map<String, dynamic>>(
        '/api/analises',
        data: any(named: 'data'),
      ),
    ).called(1);
  });

  test('analisarDeveEnviarOFormDataComOsCamposDeTextoCorretos', () async {
    late FormData formDataEnviado;
    when(
      () => client.post<Map<String, dynamic>>(
        '/api/analises',
        data: any(named: 'data'),
      ),
    ).thenAnswer((invocation) async {
      formDataEnviado = invocation.namedArguments[#data] as FormData;
      return Response(
        requestOptions: RequestOptions(path: '/api/analises'),
        statusCode: 201,
        data: {
          'analiseId': 'abc-123',
          'criadoEm': '2026-08-20T10:00:00.000Z',
          'trechos': <dynamic>[],
        },
      );
    });

    await api.analisar(
      textoOriginal: 'original',
      textoEditado: 'editado',
      manterHistorico: true,
    );

    final campos = Map.fromEntries(formDataEnviado.fields);
    expect(campos['textoOriginal'], 'original');
    expect(campos['textoEditado'], 'editado');
    expect(campos['manterHistorico'], 'true');
  });

  test('analisarDeveEnviarOArquivoQuandoInformado', () async {
    late FormData formDataEnviado;
    when(
      () => client.post<Map<String, dynamic>>(
        '/api/analises',
        data: any(named: 'data'),
      ),
    ).thenAnswer((invocation) async {
      formDataEnviado = invocation.namedArguments[#data] as FormData;
      return Response(
        requestOptions: RequestOptions(path: '/api/analises'),
        statusCode: 201,
        data: {
          'analiseId': 'abc-123',
          'criadoEm': '2026-08-20T10:00:00.000Z',
          'trechos': <dynamic>[],
        },
      );
    });

    await api.analisar(
      arquivoOriginal: ArquivoSelecionado(
        nome: 'documento.pdf',
        bytes: Uint8List.fromList([1, 2, 3]),
      ),
      textoEditado: 'editado',
      manterHistorico: true,
    );

    expect(formDataEnviado.files, hasLength(1));
    expect(formDataEnviado.files.first.key, 'arquivoOriginal');
    expect(formDataEnviado.files.first.value.filename, 'documento.pdf');
  });
}
