import 'package:divergia_app/core/widgets/app_checkbox.dart';
import 'package:divergia_app/features/auth/data/auth_api.dart';
import 'package:divergia_app/features/auth/data/models/token_acesso.dart';
import 'package:divergia_app/features/auth/data/models/usuario.dart';
import 'package:divergia_app/features/history/data/historico_api.dart';
import 'package:divergia_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthApi extends Mock implements AuthApi {}

class _MockHistoricoApi extends Mock implements HistoricoApi {}

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
  late _MockHistoricoApi historicoApi;

  setUp(() {
    FlutterSecureStoragePlatform.instance = _FakeSecureStoragePlatform();
    authApi = _MockAuthApi();
    historicoApi = _MockHistoricoApi();
    when(() => historicoApi.listar()).thenAnswer((_) async => []);
  });

  Widget buildRealApp() {
    return ProviderScope(
      overrides: [
        authApiProvider.overrideWithValue(authApi),
        historicoApiProvider.overrideWithValue(historicoApi),
      ],
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
        ),
      );

      await tester.binding.setSurfaceSize(const Size(400, 1600));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(buildRealApp());
      await tester.pump(const Duration(milliseconds: 1100));
      await tester.pumpAndSettle();
      expect(find.text('Bem-vindo'), findsOneWidget);

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

      expect(find.text('Minhas análises'), findsOneWidget);

      await tester.pumpWidget(Container());
      await tester.pumpWidget(buildRealApp());
      await tester.pump(const Duration(milliseconds: 1100));
      await tester.pumpAndSettle();

      expect(find.text('Minhas análises'), findsOneWidget);
      expect(find.text('Bem-vindo'), findsNothing);
    },
  );
}
