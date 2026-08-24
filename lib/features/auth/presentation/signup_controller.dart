import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../data/auth_api.dart';
import 'session_controller.dart';

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

  /// Cadastra e, em seguida, já autentica com as mesmas credenciais — o
  /// endpoint de cadastro não devolve token, só o de login devolve.
  Future<bool> submit({
    required String nome,
    required String email,
    required String senha,
  }) async {
    state = state.copyWith(loading: true, errorMessage: null);
    try {
      await _authApi.cadastrar(nome: nome, email: email, senha: senha);
      final token = await _authApi.login(email: email, senha: senha);
      await _sessionController.onLoginSuccess(
        accessToken: token.accessToken,
        expiraEm: token.expiraEm,
      );
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
