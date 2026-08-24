import 'package:dio/dio.dart';

import 'api_exception.dart';

/// Traduz toda falha do Dio para uma [ApiException] tipada, num único
/// lugar — nenhuma tela deve interpretar `DioException`/status code por
/// conta própria.
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    handler.next(err.copyWith(error: _mapError(err)));
  }

  ApiException _mapError(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
      case DioExceptionType.connectionError:
        return const NetworkException();
      case DioExceptionType.badCertificate:
        return const NetworkException('Conexão não confiável com o servidor.');
      case DioExceptionType.cancel:
        return const NetworkException('Requisição cancelada.');
      case DioExceptionType.badResponse:
        return _mapStatusCode(err);
      case DioExceptionType.unknown:
        return const NetworkException();
    }
  }

  ApiException _mapStatusCode(DioException err) {
    final statusCode = err.response?.statusCode;
    final serverMessage = _extractServerMessage(err.response?.data);

    return switch (statusCode) {
      401 => UnauthorizedException(
        serverMessage ?? const UnauthorizedException().message,
      ),
      403 => ForbiddenException(
        serverMessage ?? const ForbiddenException().message,
      ),
      404 => NotFoundException(
        serverMessage ?? const NotFoundException().message,
      ),
      400 || 409 || 422 => ValidationException(
        serverMessage ?? 'Não foi possível concluir a operação.',
      ),
      _ => ServerException(serverMessage ?? const ServerException().message),
    };
  }

  String? _extractServerMessage(dynamic data) {
    if (data is Map && data['message'] is String) {
      return data['message'] as String;
    }
    return null;
  }
}
