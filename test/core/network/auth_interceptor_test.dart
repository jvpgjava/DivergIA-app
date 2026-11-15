import 'package:dio/dio.dart';
import 'package:divergia_app/core/network/auth_interceptor.dart';
import 'package:divergia_app/core/storage/secure_token_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockTokenStorage extends Mock implements SecureTokenStorage {}

class _FakeRequestHandler extends RequestInterceptorHandler {
  RequestOptions? passed;

  @override
  void next(RequestOptions options) {
    passed = options;
  }
}

class _FakeErrorHandler extends ErrorInterceptorHandler {
  @override
  void next(DioException err) {}
}

void main() {
  late _MockTokenStorage tokenStorage;
  late AuthInterceptor interceptor;
  late int sessoesInvalidadas;
  late RequestOptions requestOptions;

  setUp(() {
    tokenStorage = _MockTokenStorage();
    sessoesInvalidadas = 0;
    interceptor = AuthInterceptor(
      tokenStorage,
      onSessaoInvalida: () async => sessoesInvalidadas++,
    );
    requestOptions = RequestOptions(path: '/api/historico');
  });

  test('deveAnexarTokenNoCabecalhoQuandoExistir', () async {
    when(
      () => tokenStorage.readAccessToken(),
    ).thenAnswer((_) async => 'token-abc');
    final handler = _FakeRequestHandler();

    await interceptor.onRequest(requestOptions, handler);

    expect(handler.passed!.headers['Authorization'], 'Bearer token-abc');
  });

  test('naoDeveAnexarCabecalhoQuandoNaoHouverToken', () async {
    when(() => tokenStorage.readAccessToken()).thenAnswer((_) async => null);
    final handler = _FakeRequestHandler();

    await interceptor.onRequest(requestOptions, handler);

    expect(handler.passed!.headers.containsKey('Authorization'), isFalse);
  });

  test('401DeRequisicaoComTokenEncerraASessao', () async {
    when(() => tokenStorage.clear()).thenAnswer((_) async {});
    final comToken = RequestOptions(
      path: '/api/historico',
      headers: {'Authorization': 'Bearer token-abc'},
    );
    final err = DioException(
      requestOptions: comToken,
      response: Response(requestOptions: comToken, statusCode: 401),
    );

    await interceptor.onError(err, _FakeErrorHandler());

    expect(sessoesInvalidadas, 1);
  });

  test('401SemTokenEnviadoEhLoginRecusadoENaoEncerraSessao', () async {
    when(() => tokenStorage.clear()).thenAnswer((_) async {});
    final err = DioException(
      requestOptions: requestOptions,
      response: Response(requestOptions: requestOptions, statusCode: 401),
    );

    await interceptor.onError(err, _FakeErrorHandler());

    expect(sessoesInvalidadas, 0);
  });

  test('outrosErrosNaoEncerramASessao', () async {
    final comToken = RequestOptions(
      path: '/api/dev/estatisticas',
      headers: {'Authorization': 'Bearer token-abc'},
    );
    final err = DioException(
      requestOptions: comToken,
      response: Response(requestOptions: comToken, statusCode: 403),
    );

    await interceptor.onError(err, _FakeErrorHandler());

    expect(sessoesInvalidadas, 0);
    verifyNever(() => tokenStorage.clear());
  });

  test('deveLimparStorageQuandoRespostaFor401', () async {
    when(() => tokenStorage.clear()).thenAnswer((_) async {});
    final err = DioException(
      requestOptions: requestOptions,
      response: Response(requestOptions: requestOptions, statusCode: 401),
    );

    await interceptor.onError(err, _FakeErrorHandler());

    verify(() => tokenStorage.clear()).called(1);
  });
}
