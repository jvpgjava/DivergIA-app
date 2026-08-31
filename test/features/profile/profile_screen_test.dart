import 'package:divergia_app/core/network/api_exception.dart';
import 'package:divergia_app/core/storage/secure_token_storage.dart';
import 'package:divergia_app/core/theme/app_theme.dart';
import 'package:divergia_app/core/theme/theme_mode_controller.dart';
import 'package:divergia_app/features/auth/data/auth_api.dart';
import 'package:divergia_app/features/auth/data/models/usuario.dart';
import 'package:divergia_app/features/auth/presentation/session_controller.dart';
import 'package:divergia_app/features/history/data/historico_api.dart';
import 'package:divergia_app/features/profile/data/consentimento_api.dart';
import 'package:divergia_app/features/profile/data/models/consentimento.dart';
import 'package:divergia_app/features/profile/presentation/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MockAuthApi extends Mock implements AuthApi {}

class _MockConsentimentoApi extends Mock implements ConsentimentoApi {}

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
  late _MockConsentimentoApi consentimentoApi;
  late _MockHistoricoApi historicoApi;

  final usuario = Usuario(
    id: 'usuario-1',
    nome: 'Ana Clara',
    email: 'ana.clara@example.com',
    criadoEm: DateTime.now(),
  );
  final consentimento = Consentimento(
    manterHistorico: true,
    contribuirParaRag: false,
    concedidoEm: DateTime.now(),
  );

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStoragePlatform.instance = _FakeSecureStoragePlatform();

    authApi = _MockAuthApi();
    consentimentoApi = _MockConsentimentoApi();
    historicoApi = _MockHistoricoApi();

    when(() => authApi.me()).thenAnswer((_) async => usuario);
    when(
      () => consentimentoApi.obter(),
    ).thenAnswer((_) async => consentimento);
  });

  Widget buildApp() {
    return ProviderScope(
      overrides: [
        authApiProvider.overrideWithValue(authApi),
        consentimentoApiProvider.overrideWithValue(consentimentoApi),
        historicoApiProvider.overrideWithValue(historicoApi),
        sessionControllerProvider.overrideWith(
          (ref) => SessionController(
            SecureTokenStorage(),
            duracaoMinimaSplash: Duration.zero,
          ),
        ),
      ],
      child: MaterialApp(theme: AppTheme.light, home: const ProfileScreen()),
    );
  }

  /// A tela de Perfil tem vários cards e não cabe no viewport padrão de
  /// teste (800x600) — usa um viewport bem alto pra tudo (inclusive "Sair
  /// da conta", o último item) ficar montado sem precisar rolar.
  Future<void> pumpProfileScreen(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();
  }

  Finder switchNaLinhaDoRotulo(String rotulo) {
    final linha = find
        .ancestor(of: find.text(rotulo), matching: find.byType(Row))
        .first;
    return find.descendant(of: linha, matching: find.byType(Switch));
  }

  testWidgets('deveMostrarNomeEEmailDoUsuarioECardsDeConfiguracao', (
    tester,
  ) async {
    await pumpProfileScreen(tester);

    expect(find.text('Ana Clara'), findsOneWidget);
    expect(find.text('ana.clara@example.com'), findsOneWidget);
    expect(find.text('Notificações push'), findsOneWidget);
    expect(find.text('Modo escuro'), findsOneWidget);
    expect(find.text('Status de consentimento'), findsOneWidget);
    expect(find.text('Ativo'), findsOneWidget);
    expect(find.text('Excluir histórico de análises'), findsOneWidget);
    expect(find.text('Excluir conta'), findsOneWidget);
    expect(find.text('Sair da conta'), findsOneWidget);
  });

  testWidgets('deveMostrarErroComBotaoDeTentarNovamenteQuandoAChamadaFalha', (
    tester,
  ) async {
    when(() => authApi.me()).thenThrow(const NetworkException());

    await pumpProfileScreen(tester);

    expect(find.text('Tentar novamente'), findsOneWidget);
  });

  testWidgets('deveAlternarOModoEscuroAoTocarNoSwitch', (tester) async {
    await pumpProfileScreen(tester);

    final container = ProviderScope.containerOf(
      tester.element(find.byType(ProfileScreen)),
    );
    expect(container.read(themeModeControllerProvider), ThemeMode.light);

    await tester.tap(switchNaLinhaDoRotulo('Modo escuro'));
    await tester.pump();

    expect(container.read(themeModeControllerProvider), ThemeMode.dark);
  });

  testWidgets(
    'deveAvisarQueNotificacoesPushNaoEstaDisponivelAoTocarNoSwitch',
    (tester) async {
      await pumpProfileScreen(tester);

      await tester.tap(switchNaLinhaDoRotulo('Notificações push'));
      await tester.pump();

      expect(
        find.text('Notificações push ainda não disponível.'),
        findsOneWidget,
      );
    },
  );

  testWidgets('deveExcluirOHistoricoAoConfirmarNoDialogo', (tester) async {
    when(() => historicoApi.excluirTudo()).thenAnswer((_) async {});

    await pumpProfileScreen(tester);

    await tester.tap(find.text('Excluir histórico de análises'));
    await tester.pumpAndSettle();

    expect(find.text('Excluir histórico de análises'), findsWidgets);
    await tester.tap(find.text('Excluir'));
    await tester.pumpAndSettle();

    verify(() => historicoApi.excluirTudo()).called(1);
    expect(find.text('Histórico excluído.'), findsOneWidget);
  });

  testWidgets('naoDeveExcluirOHistoricoAoCancelarNoDialogo', (tester) async {
    await pumpProfileScreen(tester);

    await tester.tap(find.text('Excluir histórico de análises'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();

    verifyNever(() => historicoApi.excluirTudo());
  });

  testWidgets('deveExcluirAContaAoConfirmarNoDialogo', (tester) async {
    when(() => authApi.excluirConta()).thenAnswer((_) async {});

    await pumpProfileScreen(tester);

    await tester.tap(find.text('Excluir conta'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Excluir conta').last);
    await tester.pumpAndSettle();

    verify(() => authApi.excluirConta()).called(1);
  });

  testWidgets('deveFazerLogoutAoConfirmarNoDialogo', (tester) async {
    when(() => authApi.logout()).thenAnswer((_) async {});

    await pumpProfileScreen(tester);

    await tester.tap(find.text('Sair da conta'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Sair'));
    await tester.pumpAndSettle();

    verify(() => authApi.logout()).called(1);
  });

  testWidgets('deveAlterarASenhaAoPreencherOFormularioEConfirmar', (
    tester,
  ) async {
    when(
      () => authApi.alterarSenha(
        senhaAtual: 'senhaAtual1',
        novaSenha: 'senhaNova1',
      ),
    ).thenAnswer((_) async {});

    await pumpProfileScreen(tester);

    await tester.tap(find.text('Alterar senha'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Sua senha atual'),
      'senhaAtual1',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Crie uma senha forte'),
      'senhaNova1',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Repita a nova senha'),
      'senhaNova1',
    );
    await tester.tap(find.text('Salvar nova senha'));
    await tester.pumpAndSettle();

    verify(
      () => authApi.alterarSenha(
        senhaAtual: 'senhaAtual1',
        novaSenha: 'senhaNova1',
      ),
    ).called(1);
    expect(find.text('Senha alterada.'), findsOneWidget);
  });

  testWidgets(
    'deveAlterarOEmailAoPreencherOFormularioEConfirmarERefletirNoAvatarCard',
    (tester) async {
      final atualizado = Usuario(
        id: usuario.id,
        nome: usuario.nome,
        email: 'novo@example.com',
        criadoEm: usuario.criadoEm,
      );
      when(
        () => authApi.alterarEmail(
          novoEmail: 'novo@example.com',
          senhaAtual: 'senhaAtual1',
        ),
      ).thenAnswer((_) async => atualizado);

      await pumpProfileScreen(tester);

      await tester.tap(find.text('Alterar e-mail'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'novo@email.com'),
        'novo@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Confirme sua senha'),
        'senhaAtual1',
      );
      await tester.tap(find.text('Salvar novo e-mail'));
      await tester.pumpAndSettle();

      expect(find.text('E-mail alterado.'), findsOneWidget);
      expect(find.text('novo@example.com'), findsOneWidget);
    },
  );

  testWidgets(
    'deveAbrirOBottomSheetDeConsentimentoEAtualizarAoAlternarUmSwitch',
    (tester) async {
      final atualizado = Consentimento(
        manterHistorico: false,
        contribuirParaRag: false,
        concedidoEm: DateTime.now(),
      );
      when(
        () => consentimentoApi.atualizar(
          manterHistorico: false,
          contribuirParaRag: false,
        ),
      ).thenAnswer((_) async => atualizado);

      await pumpProfileScreen(tester);

      await tester.tap(find.text('Status de consentimento'));
      await tester.pumpAndSettle();

      expect(find.text('Manter histórico das análises'), findsOneWidget);

      await tester.tap(switchNaLinhaDoRotulo('Manter histórico das análises'));
      await tester.pumpAndSettle();

      verify(
        () => consentimentoApi.atualizar(
          manterHistorico: false,
          contribuirParaRag: false,
        ),
      ).called(1);
    },
  );
}
