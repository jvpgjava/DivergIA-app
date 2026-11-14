import 'package:dio/dio.dart';

import 'api_exception.dart';

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
        codigo: _extractString(err.response?.data, 'codigo'),
        campo: _extractString(err.response?.data, 'campo'),
      ),
      // O rate limit do backend responde sem corpo; "erro inesperado" faria parecer que o app quebrou.
      429 => ServerException(
        serverMessage ??
            'Muitas tentativas em pouco tempo. Aguarde um minuto e tente novamente.',
      ),
      _ => ServerException(serverMessage ?? const ServerException().message),
    };
  }

  String? _extractServerMessage(dynamic data) => _extractString(data, 'message');

  String? _extractString(dynamic data, String key) {
    if (data is Map && data[key] is String) {
      final valor = (data[key] as String).trim();
      return valor.isEmpty ? null : valor;
    }
    return null;
  }
}
