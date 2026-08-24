/// Erro de rede/API já traduzido para algo que a camada de apresentação
/// pode exibir diretamente, sem vazar detalhe de implementação do Dio.
sealed class ApiException implements Exception {
  const ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Sem conexão, timeout, ou o servidor não respondeu.
class NetworkException extends ApiException {
  const NetworkException([
    super.message =
        'Sem conexão com o servidor. Verifique sua internet e tente novamente.',
  ]);
}

/// 401 — token ausente, inválido ou expirado.
class UnauthorizedException extends ApiException {
  const UnauthorizedException([
    super.message = 'Sessão expirada. Faça login novamente.',
  ]);
}

/// 403 — usuário autenticado, mas sem permissão para o recurso.
class ForbiddenException extends ApiException {
  const ForbiddenException([
    super.message = 'Você não tem permissão para essa ação.',
  ]);
}

/// 404.
class NotFoundException extends ApiException {
  const NotFoundException([super.message = 'Recurso não encontrado.']);
}

/// 400/422 com mensagem de validação vinda do backend.
class ValidationException extends ApiException {
  const ValidationException(super.message);
}

/// 5xx ou qualquer outro erro não mapeado explicitamente.
class ServerException extends ApiException {
  const ServerException([
    super.message =
        'Erro inesperado no servidor. Tente novamente em instantes.',
  ]);
}
