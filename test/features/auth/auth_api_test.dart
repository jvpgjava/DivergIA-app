import 'package:dio/dio.dart';
import 'package:divergia_app/core/network/api_client.dart';
import 'package:divergia_app/features/auth/data/auth_api.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockApiClient extends Mock implements ApiClient {}

Response<Map<String, dynamic>> _jsonResponse(Map<String, dynamic> data) {
  return Response(
    requestOptions: RequestOptions(path: '/qualquer'),
    data: data,
    statusCode: 200,
  );
}

void main() {
  late _MockApiClient client;
  late AuthApi authApi;

  setUp(() {
    client = _MockApiClient();
    authApi = AuthApi(client);
  });

  test('cadastrarDeveChamarOEndpointCertoEMapearAResposta', () async {
    when(
      () => client.post<Map<String, dynamic>>(
        '/api/auth/cadastro',
        data: {
          'nome': 'Ana',
          'email': 'ana@example.com',
          'senha': 'senha12345',
        },
      ),
    ).thenAnswer(
      (_) async => _jsonResponse({
        'id': 'abc-123',
        'nome': 'Ana',
        'email': 'ana@example.com',
        'criadoEm': '2026-01-01T10:00:00.000Z',
      }),
    );

    final usuario = await authApi.cadastrar(
      nome: 'Ana',
      email: 'ana@example.com',
      senha: 'senha12345',
    );

    expect(usuario.id, 'abc-123');
    expect(usuario.nome, 'Ana');
    expect(usuario.email, 'ana@example.com');
  });

  test('loginDeveChamarOEndpointCertoEMapearOToken', () async {
    when(
      () => client.post<Map<String, dynamic>>(
        '/api/auth/login',
        data: {'email': 'ana@example.com', 'senha': 'senha12345'},
      ),
    ).thenAnswer(
      (_) async => _jsonResponse({
        'accessToken': 'jwt-abc',
        'expiraEm': '2026-01-01T10:15:00.000Z',
      }),
    );

    final token = await authApi.login(
      email: 'ana@example.com',
      senha: 'senha12345',
    );

    expect(token.accessToken, 'jwt-abc');
    expect(token.expiraEm, DateTime.parse('2026-01-01T10:15:00.000Z'));
  });

  test('recuperarSenhaDeveChamarOEndpointComOEmail', () async {
    when(
      () => client.post<void>(
        '/api/auth/recuperar-senha',
        data: {'email': 'ana@example.com'},
      ),
    ).thenAnswer(
      (_) async => Response(requestOptions: RequestOptions(path: '/qualquer')),
    );

    await authApi.recuperarSenha('ana@example.com');

    verify(
      () => client.post<void>(
        '/api/auth/recuperar-senha',
        data: {'email': 'ana@example.com'},
      ),
    ).called(1);
  });

  test('redefinirSenhaDeveChamarOEndpointComTokenENovaSenha', () async {
    when(
      () => client.post<void>(
        '/api/auth/redefinir-senha',
        data: {'token': 'codigo-123', 'novaSenha': 'novaSenha123'},
      ),
    ).thenAnswer(
      (_) async => Response(requestOptions: RequestOptions(path: '/qualquer')),
    );

    await authApi.redefinirSenha(
      token: 'codigo-123',
      novaSenha: 'novaSenha123',
    );

    verify(
      () => client.post<void>(
        '/api/auth/redefinir-senha',
        data: {'token': 'codigo-123', 'novaSenha': 'novaSenha123'},
      ),
    ).called(1);
  });

  test('logoutDeveChamarOEndpointSemCorpo', () async {
    when(() => client.post<void>('/api/auth/logout')).thenAnswer(
      (_) async => Response(requestOptions: RequestOptions(path: '/qualquer')),
    );

    await authApi.logout();

    verify(() => client.post<void>('/api/auth/logout')).called(1);
  });

  test('meDeveChamarOEndpointCertoEMapearOUsuarioLogado', () async {
    when(() => client.get<Map<String, dynamic>>('/api/auth/me')).thenAnswer(
      (_) async => _jsonResponse({
        'id': 'abc-123',
        'nome': 'Ana Clara',
        'email': 'ana@example.com',
        'criadoEm': '2026-01-01T10:00:00.000Z',
      }),
    );

    final usuario = await authApi.me();

    expect(usuario.id, 'abc-123');
    expect(usuario.nome, 'Ana Clara');
    expect(usuario.email, 'ana@example.com');
  });

  test('excluirContaDeveChamarOEndpointCorreto', () async {
    when(() => client.delete<void>('/api/auth/conta')).thenAnswer(
      (_) async => Response(requestOptions: RequestOptions(path: '/qualquer')),
    );

    await authApi.excluirConta();

    verify(() => client.delete<void>('/api/auth/conta')).called(1);
  });
}
