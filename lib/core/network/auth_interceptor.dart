import 'package:dio/dio.dart';

import '../storage/secure_token_storage.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._tokenStorage, {this.onSessaoInvalida});

  final SecureTokenStorage _tokenStorage;

  // Chamado quando o servidor recusa um token que o app enviou (token revogado ou inválido).
  final Future<void> Function()? onSessaoInvalida;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _tokenStorage.readAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      await _tokenStorage.clear();
      // 401 sem token enviado é login recusado, não sessão perdida.
      if (err.requestOptions.headers.containsKey('Authorization')) {
        await onSessaoInvalida?.call();
      }
    }
    handler.next(err);
  }
}
