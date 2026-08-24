import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../data/auth_api.dart';

class RedefinirSenhaState {
  const RedefinirSenhaState({
    this.loading = false,
    this.redefinido = false,
    this.errorMessage,
  });

  final bool loading;
  final bool redefinido;
  final String? errorMessage;
}

class RedefinirSenhaController extends StateNotifier<RedefinirSenhaState> {
  RedefinirSenhaController(this._authApi) : super(const RedefinirSenhaState());

  final AuthApi _authApi;

  Future<void> submit({
    required String token,
    required String novaSenha,
  }) async {
    state = const RedefinirSenhaState(loading: true);
    try {
      await _authApi.redefinirSenha(token: token, novaSenha: novaSenha);
      state = const RedefinirSenhaState(redefinido: true);
    } on ApiException catch (e) {
      state = RedefinirSenhaState(errorMessage: e.message);
    }
  }
}

final redefinirSenhaControllerProvider =
    StateNotifierProvider.autoDispose<
      RedefinirSenhaController,
      RedefinirSenhaState
    >((ref) => RedefinirSenhaController(ref.watch(authApiProvider)));
