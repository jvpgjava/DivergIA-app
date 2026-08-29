import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../auth/data/auth_api.dart';
import '../../auth/data/models/usuario.dart';
import '../../auth/presentation/session_controller.dart';
import '../../history/data/historico_api.dart';
import '../data/consentimento_api.dart';
import '../data/models/consentimento.dart';

class ProfileState {
  const ProfileState({
    this.loading = false,
    this.errorMessage,
    this.usuario,
    this.consentimento,
  });

  final bool loading;
  final String? errorMessage;
  final Usuario? usuario;
  final Consentimento? consentimento;
}

/// Carrega os dados da conta (`GET /api/auth/me`) e o consentimento
/// (`GET /api/consentimento`) assim que criado, e expõe as ações da tela de
/// Perfil que de fato têm um endpoint real por trás: atualizar
/// consentimento, excluir histórico, excluir conta e logout (este último
/// já revoga o token no servidor — ver [AuthApi.logout] — não é só limpar
/// o storage local).
class ProfileController extends StateNotifier<ProfileState> {
  ProfileController(
    this._authApi,
    this._consentimentoApi,
    this._historicoApi,
    this._sessionController,
  ) : super(const ProfileState(loading: true)) {
    carregar();
  }

  final AuthApi _authApi;
  final ConsentimentoApi _consentimentoApi;
  final HistoricoApi _historicoApi;
  final SessionController _sessionController;

  Future<void> carregar() async {
    state = const ProfileState(loading: true);
    try {
      final usuario = await _authApi.me();
      final consentimento = await _consentimentoApi.obter();
      state = ProfileState(
        loading: false,
        usuario: usuario,
        consentimento: consentimento,
      );
    } on ApiException catch (e) {
      state = ProfileState(loading: false, errorMessage: e.message);
    }
  }

  Future<bool> atualizarConsentimento({
    required bool manterHistorico,
    required bool contribuirParaRag,
  }) async {
    try {
      final atualizado = await _consentimentoApi.atualizar(
        manterHistorico: manterHistorico,
        contribuirParaRag: contribuirParaRag,
      );
      state = ProfileState(
        loading: false,
        usuario: state.usuario,
        consentimento: atualizado,
      );
      return true;
    } on ApiException {
      return false;
    }
  }

  Future<bool> excluirHistorico() async {
    try {
      await _historicoApi.excluirTudo();
      return true;
    } on ApiException {
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _authApi.logout();
    } on ApiException {
      // Mesmo se a chamada falhar (ex: sem rede), ainda limpa a sessão
      // local — não faz sentido prender a pessoa numa tela autenticada só
      // porque o logout no servidor não confirmou.
    }
    await _sessionController.onLogout();
  }

  Future<bool> excluirConta() async {
    try {
      await _authApi.excluirConta();
      await _sessionController.onLogout();
      return true;
    } on ApiException {
      return false;
    }
  }
}

final profileControllerProvider =
    StateNotifierProvider.autoDispose<ProfileController, ProfileState>((ref) {
      return ProfileController(
        ref.watch(authApiProvider),
        ref.watch(consentimentoApiProvider),
        ref.watch(historicoApiProvider),
        ref.watch(sessionControllerProvider.notifier),
      );
    });
