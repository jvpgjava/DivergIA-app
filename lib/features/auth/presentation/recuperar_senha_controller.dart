import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../data/auth_api.dart';

class RecuperarSenhaState {
  const RecuperarSenhaState({
    this.loading = false,
    this.enviado = false,
    this.errorMessage,
  });

  final bool loading;
  final bool enviado;
  final String? errorMessage;
}

class RecuperarSenhaController extends StateNotifier<RecuperarSenhaState> {
  RecuperarSenhaController(this._authApi) : super(const RecuperarSenhaState());

  final AuthApi _authApi;

  Future<void> submit(String email) async {
    state = const RecuperarSenhaState(loading: true);
    try {
      await _authApi.recuperarSenha(email);
      state = const RecuperarSenhaState(enviado: true);
    } on ApiException catch (e) {
      state = RecuperarSenhaState(errorMessage: e.message);
    }
  }
}

final recuperarSenhaControllerProvider =
    StateNotifierProvider.autoDispose<
      RecuperarSenhaController,
      RecuperarSenhaState
    >((ref) => RecuperarSenhaController(ref.watch(authApiProvider)));
