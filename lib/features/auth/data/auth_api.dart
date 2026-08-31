import 'package:dio/dio.dart';
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

  Future<Usuario> me() async {
    final response = await _client.get<Map<String, dynamic>>('/api/auth/me');
    return Usuario.fromJson(response.data!);
  }

  Future<void> excluirConta() => _client.delete<void>('/api/auth/conta');

  Future<void> recuperarSenha(String email) =>
      _client.post<void>('/api/auth/recuperar-senha', data: {'email': email});

  Future<void> redefinirSenha({
    required String token,
    required String novaSenha,
  }) => _client.post<void>(
    '/api/auth/redefinir-senha',
    data: {'token': token, 'novaSenha': novaSenha},
  );

  Future<void> alterarSenha({
    required String senhaAtual,
    required String novaSenha,
  }) => _client.put<void>(
    '/api/auth/senha',
    data: {'senhaAtual': senhaAtual, 'novaSenha': novaSenha},
  );

  Future<Usuario> alterarEmail({
    required String novoEmail,
    required String senhaAtual,
  }) async {
    final response = await _client.put<Map<String, dynamic>>(
      '/api/auth/email',
      data: {'novoEmail': novoEmail, 'senhaAtual': senhaAtual},
    );
    return Usuario.fromJson(response.data!);
  }

  Future<String> atualizarFotoPerfil({
    required List<int> bytes,
    required String nomeArquivo,
  }) async {
    final formData = FormData.fromMap({
      'foto': MultipartFile.fromBytes(bytes, filename: nomeArquivo),
    });
    final response = await _client.post<Map<String, dynamic>>(
      '/api/auth/foto',
      data: formData,
    );
    return response.data!['fotoUrl'] as String;
  }
}

final authApiProvider = Provider<AuthApi>((ref) {
  return AuthApi(ref.watch(apiClientProvider));
});
