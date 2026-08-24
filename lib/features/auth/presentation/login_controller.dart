import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../data/auth_api.dart';
import 'session_controller.dart';

class LoginState {
  const LoginState({this.loading = false, this.errorMessage});

  final bool loading;
  final String? errorMessage;

  LoginState copyWith({bool? loading, String? errorMessage}) =>
      LoginState(loading: loading ?? this.loading, errorMessage: errorMessage);
}

class LoginController extends StateNotifier<LoginState> {
  LoginController(this._authApi, this._sessionController)
    : super(const LoginState());

  final AuthApi _authApi;
  final SessionController _sessionController;

  Future<bool> submit({required String email, required String senha}) async {
    state = state.copyWith(loading: true, errorMessage: null);
    try {
      final token = await _authApi.login(email: email, senha: senha);
      await _sessionController.onLoginSuccess(
        accessToken: token.accessToken,
        expiraEm: token.expiraEm,
      );
      state = state.copyWith(loading: false);
      return true;
    } on ApiException catch (e) {
      state = LoginState(loading: false, errorMessage: e.message);
      return false;
    }
  }
}

final loginControllerProvider =
    StateNotifierProvider.autoDispose<LoginController, LoginState>((ref) {
      return LoginController(
        ref.watch(authApiProvider),
        ref.watch(sessionControllerProvider.notifier),
      );
    });
