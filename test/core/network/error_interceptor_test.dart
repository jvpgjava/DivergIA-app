import 'package:dio/dio.dart';
import 'package:divergia_app/core/network/api_exception.dart';
import 'package:divergia_app/core/network/error_interceptor.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeErrorHandler extends ErrorInterceptorHandler {
  DioException? passed;

  @override
  void next(DioException err) {
    passed = err;
  }
}

void main() {
  late ErrorInterceptor interceptor;
  final requestOptions = RequestOptions(path: '/qualquer');

  setUp(() => interceptor = ErrorInterceptor());

  DioException errorWithStatus(int statusCode, {dynamic data}) {
    return DioException(
      requestOptions: requestOptions,
      type: DioExceptionType.badResponse,
      response: Response(
        requestOptions: requestOptions,
        statusCode: statusCode,
        data: data,
      ),
    );
  }

  test('deveMapear401ParaUnauthorizedException', () {
    final handler = _FakeErrorHandler();

    interceptor.onError(errorWithStatus(401), handler);

    expect(handler.passed!.error, isA<UnauthorizedException>());
  });

  test('deveMapear403ParaForbiddenException', () {
    final handler = _FakeErrorHandler();

    interceptor.onError(errorWithStatus(403), handler);

    expect(handler.passed!.error, isA<ForbiddenException>());
  });

  test('deveMapear404ParaNotFoundException', () {
    final handler = _FakeErrorHandler();

    interceptor.onError(errorWithStatus(404), handler);

    expect(handler.passed!.error, isA<NotFoundException>());
  });

  test('deveMapear500ParaServerException', () {
    final handler = _FakeErrorHandler();

    interceptor.onError(errorWithStatus(500), handler);

    expect(handler.passed!.error, isA<ServerException>());
  });

  test('deveUsarMensagemDoBackendQuandoPresente', () {
    final handler = _FakeErrorHandler();

    interceptor.onError(
      errorWithStatus(409, data: {'message': 'E-mail já cadastrado'}),
      handler,
    );

    expect(
      (handler.passed!.error as ApiException).message,
      'E-mail já cadastrado',
    );
  });

  test('deveMapearTimeoutParaNetworkException', () {
    final handler = _FakeErrorHandler();
    final timeoutError = DioException(
      requestOptions: requestOptions,
      type: DioExceptionType.connectionTimeout,
    );

    interceptor.onError(timeoutError, handler);

    expect(handler.passed!.error, isA<NetworkException>());
  });
}
