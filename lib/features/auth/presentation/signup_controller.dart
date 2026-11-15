import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../data/auth_api.dart';
import '../data/models/token_acesso.dart';
import 'session_controller.dart';

const emailIndisponivel =
    'Não foi possível criar a conta com esse e-mail. Se você já tem conta, entre ou recupere a senha.';

class SignupState {
  const SignupState({this.loading = false, this.errorMessage});

  final bool loading;
  final String? errorMessage;

  SignupState copyWith({bool? loading, String? errorMessage}) =>
      SignupState(loading: loading ?? this.loading, errorMessage: errorMessage);
}

class SignupController extends StateNotifier<SignupState> {
  SignupController(this._authApi, this._sessionController)
    : super(const SignupState());

  final AuthApi _authApi;
  final SessionController _sessionController;

  Future<bool> submit({
    required String nome,
    required String email,
    required String senha,
  }) async {
    state = state.copyWith(loading: true, errorMessage: null);
    try {
      await _authApi.cadastrar(nome: nome, email: email, senha: senha);
      final TokenAcesso token;
      try {
        token = await _authApi.login(email: email, senha: senha);
      } on UnauthorizedException {
        // O servidor não revela se o e-mail já tem conta: o cadastro "passa" e só o login falha.
        throw const ValidationException(emailIndisponivel);
      }
      await _sessionController.onLoginSuccess(accessToken: token.accessToken);
      state = state.copyWith(loading: false);
      return true;
    } on ApiException catch (e) {
      state = SignupState(loading: false, errorMessage: e.message);
      return false;
    }
  }
}

final signupControllerProvider =
    StateNotifierProvider.autoDispose<SignupController, SignupState>((ref) {
      return SignupController(
        ref.watch(authApiProvider),
        ref.watch(sessionControllerProvider.notifier),
      );
    });
