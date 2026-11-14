import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../auth/data/auth_api.dart';
import '../../auth/data/models/usuario.dart';
import '../../auth/presentation/session_controller.dart';
import '../../history/data/historico_api.dart';

class ProfileState {
  const ProfileState({this.loading = false, this.errorMessage, this.usuario});

  final bool loading;
  final String? errorMessage;
  final Usuario? usuario;
}

class ProfileController extends StateNotifier<ProfileState> {
  ProfileController(this._authApi, this._historicoApi, this._sessionController)
    : super(const ProfileState(loading: true)) {
    carregar();
  }

  final AuthApi _authApi;
  final HistoricoApi _historicoApi;
  final SessionController _sessionController;

  Future<void> carregar() async {
    state = const ProfileState(loading: true);
    try {
      final usuario = await _authApi.me();
      state = ProfileState(loading: false, usuario: usuario);
    } on ApiException catch (e) {
      state = ProfileState(loading: false, errorMessage: e.message);
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
      // Falha ao revogar o token no servidor não pode impedir a pessoa de sair no aparelho.
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

  Future<String?> alterarSenha({
    required String senhaAtual,
    required String novaSenha,
  }) async {
    try {
      await _authApi.alterarSenha(senhaAtual: senhaAtual, novaSenha: novaSenha);
      return null;
    } on ApiException catch (e) {
      return e.message;
    }
  }

  Future<String?> alterarEmail({
    required String novoEmail,
    required String senhaAtual,
  }) async {
    try {
      final atualizado = await _authApi.alterarEmail(
        novoEmail: novoEmail,
        senhaAtual: senhaAtual,
      );
      state = ProfileState(loading: false, usuario: atualizado);
      return null;
    } on ApiException catch (e) {
      return e.message;
    }
  }

  Future<String?> atualizarFotoPerfil({
    required List<int> bytes,
    required String nomeArquivo,
  }) async {
    try {
      final fotoUrl = await _authApi.atualizarFotoPerfil(
        bytes: bytes,
        nomeArquivo: nomeArquivo,
      );
      state = ProfileState(
        loading: false,
        usuario: state.usuario?.copyWith(fotoUrl: fotoUrl),
      );
      return null;
    } on ApiException catch (e) {
      return e.message;
    }
  }
}

final profileControllerProvider =
    StateNotifierProvider.autoDispose<ProfileController, ProfileState>((ref) {
      return ProfileController(
        ref.watch(authApiProvider),
        ref.watch(historicoApiProvider),
        ref.watch(sessionControllerProvider.notifier),
      );
    });
