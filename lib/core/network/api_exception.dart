sealed class ApiException implements Exception {
  const ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class NetworkException extends ApiException {
  const NetworkException([
    super.message =
        'Sem conexão com o servidor. Verifique sua internet e tente novamente.',
  ]);
}

class UnauthorizedException extends ApiException {
  const UnauthorizedException([
    super.message = 'Sessão expirada. Faça login novamente.',
  ]);
}

class ForbiddenException extends ApiException {
  const ForbiddenException([
    super.message = 'Você não tem permissão para essa ação.',
  ]);
}

class NotFoundException extends ApiException {
  const NotFoundException([super.message = 'Recurso não encontrado.']);
}

class ValidationException extends ApiException {
  const ValidationException(super.message, {this.codigo, this.campo});

  final String? codigo;
  final String? campo;
}

class ServerException extends ApiException {
  const ServerException([
    super.message =
        'Erro inesperado no servidor. Tente novamente em instantes.',
  ]);
}
