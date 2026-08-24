import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import 'models/token_acesso.dart';
import 'models/usuario.dart';

/// Chamadas HTTP de autenticação — espelha exatamente o `AuthController` do
/// backend (`/api/auth/*`). Nenhuma tela deve montar essas rotas por conta
/// própria.
class AuthApi {
  AuthApi(this._client);

  final ApiClient _client;

  Future<Usuario> cadastrar({
    required String nome,
    required String email,
    required String senha,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/auth/cadastro',
      data: {'nome': nome, 'email': email, 'senha': senha},
    );
    return Usuario.fromJson(response.data!);
  }

  Future<TokenAcesso> login({
    required String email,
    required String senha,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/auth/login',
      data: {'email': email, 'senha': senha},
    );
    return TokenAcesso.fromJson(response.data!);
  }

  Future<void> logout() => _client.post<void>('/api/auth/logout');

  Future<void> recuperarSenha(String email) =>
      _client.post<void>('/api/auth/recuperar-senha', data: {'email': email});

  Future<void> redefinirSenha({
    required String token,
    required String novaSenha,
  }) => _client.post<void>(
    '/api/auth/redefinir-senha',
    data: {'token': token, 'novaSenha': novaSenha},
  );
}

final authApiProvider = Provider<AuthApi>((ref) {
  return AuthApi(ref.watch(apiClientProvider));
});
