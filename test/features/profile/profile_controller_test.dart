import 'package:divergia_app/core/network/api_exception.dart';
import 'package:divergia_app/features/auth/data/auth_api.dart';
import 'package:divergia_app/features/auth/data/models/usuario.dart';
import 'package:divergia_app/features/auth/presentation/session_controller.dart';
import 'package:divergia_app/features/history/data/historico_api.dart';
import 'package:divergia_app/features/profile/data/consentimento_api.dart';
import 'package:divergia_app/features/profile/data/models/consentimento.dart';
import 'package:divergia_app/features/profile/presentation/profile_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthApi extends Mock implements AuthApi {}

class _MockConsentimentoApi extends Mock implements ConsentimentoApi {}

class _MockHistoricoApi extends Mock implements HistoricoApi {}

class _MockSessionController extends Mock implements SessionController {}

void main() {
  late _MockAuthApi authApi;
  late _MockConsentimentoApi consentimentoApi;
  late _MockHistoricoApi historicoApi;
  late _MockSessionController sessionController;

  final usuario = Usuario(
    id: 'usuario-1',
    nome: 'Ana Clara',
    email: 'ana@example.com',
    criadoEm: DateTime.now(),
  );
  final consentimento = Consentimento(
    manterHistorico: true,
    contribuirParaRag: false,
    concedidoEm: DateTime.now(),
  );

  setUp(() {
    authApi = _MockAuthApi();
    consentimentoApi = _MockConsentimentoApi();
    historicoApi = _MockHistoricoApi();
    sessionController = _MockSessionController();
    when(() => sessionController.onLogout()).thenAnswer((_) async {});
  });

  ProfileController criarController() =>
      ProfileController(authApi, consentimentoApi, historicoApi, sessionController);

  test('deveCarregarUsuarioEConsentimentoAutomaticamenteAoSerCriado', () async {
    when(() => authApi.me()).thenAnswer((_) async => usuario);
    when(() => consentimentoApi.obter()).thenAnswer((_) async => consentimento);

    final controller = criarController();
    expect(controller.state.loading, isTrue);

    await Future<void>.delayed(Duration.zero);

    expect(controller.state.loading, isFalse);
    expect(controller.state.usuario, usuario);
    expect(controller.state.consentimento, consentimento);
    expect(controller.state.errorMessage, isNull);
  });

  test('deveExporMensagemDeErroQuandoOCarregamentoFalha', () async {
    when(() => authApi.me()).thenThrow(const NetworkException());

    final controller = criarController();
    await Future<void>.delayed(Duration.zero);

    expect(controller.state.loading, isFalse);
    expect(controller.state.errorMessage, isNotNull);
  });

  test('atualizarConsentimentoComSucessoDeveAtualizarOEstadoEDevolverTrue', () async {
    when(() => authApi.me()).thenAnswer((_) async => usuario);
    when(() => consentimentoApi.obter()).thenAnswer((_) async => consentimento);
    final controller = criarController();
    await Future<void>.delayed(Duration.zero);

    final atualizado = Consentimento(
      manterHistorico: false,
      contribuirParaRag: true,
      concedidoEm: DateTime.now(),
    );
    when(
      () => consentimentoApi.atualizar(
        manterHistorico: false,
        contribuirParaRag: true,
      ),
    ).thenAnswer((_) async => atualizado);

    final sucesso = await controller.atualizarConsentimento(
      manterHistorico: false,
      contribuirParaRag: true,
    );

    expect(sucesso, isTrue);
    expect(controller.state.consentimento, atualizado);
    expect(controller.state.usuario, usuario);
  });

  test('atualizarConsentimentoComFalhaDeveDevolverFalse', () async {
    when(() => authApi.me()).thenAnswer((_) async => usuario);
    when(() => consentimentoApi.obter()).thenAnswer((_) async => consentimento);
    final controller = criarController();
    await Future<void>.delayed(Duration.zero);

    when(
      () => consentimentoApi.atualizar(
        manterHistorico: any(named: 'manterHistorico'),
        contribuirParaRag: any(named: 'contribuirParaRag'),
      ),
    ).thenThrow(const NetworkException());

    final sucesso = await controller.atualizarConsentimento(
      manterHistorico: false,
      contribuirParaRag: true,
    );

    expect(sucesso, isFalse);
  });

  test('excluirHistoricoComSucessoDeveDevolverTrue', () async {
    when(() => authApi.me()).thenAnswer((_) async => usuario);
    when(() => consentimentoApi.obter()).thenAnswer((_) async => consentimento);
    when(() => historicoApi.excluirTudo()).thenAnswer((_) async {});
    final controller = criarController();
    await Future<void>.delayed(Duration.zero);

    expect(await controller.excluirHistorico(), isTrue);
  });

  test('excluirHistoricoComFalhaDeveDevolverFalse', () async {
    when(() => authApi.me()).thenAnswer((_) async => usuario);
    when(() => consentimentoApi.obter()).thenAnswer((_) async => consentimento);
    when(() => historicoApi.excluirTudo()).thenThrow(const NetworkException());
    final controller = criarController();
    await Future<void>.delayed(Duration.zero);

    expect(await controller.excluirHistorico(), isFalse);
  });

  test('logoutDeveChamarOEndpointEEncerrarASessaoMesmoQuandoAChamadaFalha', () async {
    when(() => authApi.me()).thenAnswer((_) async => usuario);
    when(() => consentimentoApi.obter()).thenAnswer((_) async => consentimento);
    when(() => authApi.logout()).thenThrow(const NetworkException());
    final controller = criarController();
    await Future<void>.delayed(Duration.zero);

    await controller.logout();

    verify(() => sessionController.onLogout()).called(1);
  });

  test('excluirContaComSucessoDeveEncerrarASessaoEDevolverTrue', () async {
    when(() => authApi.me()).thenAnswer((_) async => usuario);
    when(() => consentimentoApi.obter()).thenAnswer((_) async => consentimento);
    when(() => authApi.excluirConta()).thenAnswer((_) async {});
    final controller = criarController();
    await Future<void>.delayed(Duration.zero);

    final sucesso = await controller.excluirConta();

    expect(sucesso, isTrue);
    verify(() => sessionController.onLogout()).called(1);
  });

  test('excluirContaComFalhaDeveDevolverFalseSemEncerrarASessao', () async {
    when(() => authApi.me()).thenAnswer((_) async => usuario);
    when(() => consentimentoApi.obter()).thenAnswer((_) async => consentimento);
    when(() => authApi.excluirConta()).thenThrow(const NetworkException());
    final controller = criarController();
    await Future<void>.delayed(Duration.zero);

    final sucesso = await controller.excluirConta();

    expect(sucesso, isFalse);
    verifyNever(() => sessionController.onLogout());
  });
}
