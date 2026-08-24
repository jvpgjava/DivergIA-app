import 'package:divergia_app/core/widgets/app_checkbox.dart';
import 'package:divergia_app/features/auth/data/auth_api.dart';
import 'package:divergia_app/features/auth/data/models/token_acesso.dart';
import 'package:divergia_app/features/auth/data/models/usuario.dart';
import 'package:divergia_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthApi extends Mock implements AuthApi {}

/// Guarda estado de verdade (em memória) — usado pra simular "reiniciar o
/// app" mantendo o que o `flutter_secure_storage` teria persistido de fato
/// no dispositivo.
class _FakeSecureStoragePlatform extends FlutterSecureStoragePlatform {
  final Map<String, String> _values = {};

  @override
  Future<bool> containsKey({
    required String key,
    required Map<String, String> options,
  }) async => _values.containsKey(key);

  @override
  Future<void> delete({
    required String key,
    required Map<String, String> options,
  }) async => _values.remove(key);

  @override
  Future<void> deleteAll({required Map<String, String> options}) async =>
      _values.clear();

  @override
  Future<String?> read({
    required String key,
    required Map<String, String> options,
  }) async => _values[key];

  @override
  Future<Map<String, String>> readAll({
    required Map<String, String> options,
  }) async => Map.of(_values);

  @override
  Future<void> write({
    required String key,
    required String value,
    required Map<String, String> options,
  }) async {
    _values[key] = value;
  }
}

void main() {
  late _MockAuthApi authApi;

  setUp(() {
    FlutterSecureStoragePlatform.instance = _FakeSecureStoragePlatform();
    authApi = _MockAuthApi();
  });

  Widget buildRealApp() {
    return ProviderScope(
      overrides: [authApiProvider.overrideWithValue(authApi)],
      child: const DivergiaApp(),
    );
  }

  testWidgets(
    'fluxo completo: criar conta -> logar -> sessão persistida entre "reinícios" do app',
    (tester) async {
      when(
        () => authApi.cadastrar(
          nome: 'Ana Clara',
          email: 'ana@example.com',
          senha: 'senha12345',
        ),
      ).thenAnswer(
        (_) async => Usuario(
          id: 'abc-123',
          nome: 'Ana Clara',
          email: 'ana@example.com',
          criadoEm: DateTime.now(),
        ),
      );
      when(
        () => authApi.login(email: 'ana@example.com', senha: 'senha12345'),
      ).thenAnswer(
        (_) async => TokenAcesso(
          accessToken: 'jwt-abc',
          expiraEm: DateTime.now().add(const Duration(minutes: 15)),
        ),
      );

      // A tela de cadastro é mais alta que o viewport padrão de teste —
      // usa um viewport de celular pra não precisar rolar até os elementos.
      await tester.binding.setSurfaceSize(const Size(400, 1600));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      // 1ª "abertura" do app: sem sessão salva, cai no login.
      await tester.pumpWidget(buildRealApp());
      await tester.pumpAndSettle();
      expect(find.text('Bem-vindo'), findsOneWidget);

      // Vai pra criar conta, preenche e envia.
      await tester.tap(find.text('Criar conta'));
      await tester.pumpAndSettle();

      final campos = find.byType(TextFormField);
      await tester.enterText(campos.at(0), 'Ana Clara');
      await tester.enterText(campos.at(1), 'ana@example.com');
      await tester.enterText(campos.at(2), 'senha12345');
      await tester.enterText(campos.at(3), 'senha12345');
      await tester.tap(find.byType(AppCheckbox));
      await tester.tap(find.text('Criar conta').last);
      await tester.pumpAndSettle();

      // Cadastro + login (automático) com sucesso -> vai direto pro histórico.
      expect(find.text('Histórico'), findsWidgets);

      // 2ª "abertura" do app (mesmo storage, novo container/widget tree) —
      // a sessão salva deve pular o login e ir direto pro histórico.
      await tester.pumpWidget(Container());
      await tester.pumpWidget(buildRealApp());
      await tester.pumpAndSettle();

      expect(find.text('Histórico'), findsWidgets);
      expect(find.text('Bem-vindo'), findsNothing);
    },
  );
}
