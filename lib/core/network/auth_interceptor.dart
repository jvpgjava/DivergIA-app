import 'package:dio/dio.dart';

import '../storage/secure_token_storage.dart';

/// Anexa o token JWT em toda chamada autenticada — nunca montado
/// manualmente em cada tela, para evitar esquecimento (checklist de
/// segurança do roadmap).
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._tokenStorage);

  final SecureTokenStorage _tokenStorage;

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
    }
    handler.next(err);
  }
}
