import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/secure_token_storage.dart';

enum SessionStatus { checking, authenticated, unauthenticated }

class SessionController extends ChangeNotifier {
  SessionController(
    this._tokenStorage, {
    this.duracaoMinimaSplash = const Duration(milliseconds: 1100),
  }) {
    checkSession();
  }

  final SecureTokenStorage _tokenStorage;

  final Duration duracaoMinimaSplash;

  SessionStatus status = SessionStatus.checking;

  Future<void> checkSession() async {
    final sessaoValidaFuturo = _lerSessaoValida();
    // Pula o Timer quando zero: um Timer de duração zero ainda fica pendente em testes com um pump() solto.
    if (duracaoMinimaSplash > Duration.zero) {
      await Future.delayed(duracaoMinimaSplash);
    }
    final sessaoValida = await sessaoValidaFuturo;

    status = sessaoValida
        ? SessionStatus.authenticated
        : SessionStatus.unauthenticated;
    notifyListeners();
  }

  Future<bool> _lerSessaoValida() async {
    // A sessão não tem data de expiração: vale enquanto o token existir. Se o servidor o recusar
    // (revogado em outro aparelho, token antigo), o 401 encerra a sessão pelo AuthInterceptor.
    final token = await _tokenStorage.readAccessToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> onLoginSuccess({required String accessToken}) async {
    await _tokenStorage.saveSession(accessToken: accessToken);
    status = SessionStatus.authenticated;
    notifyListeners();
  }

  Future<void> onLogout() async {
    await _tokenStorage.clear();
    status = SessionStatus.unauthenticated;
    notifyListeners();
  }
}

final sessionControllerProvider = ChangeNotifierProvider<SessionController>((
  ref,
) {
  return SessionController(ref.watch(secureTokenStorageProvider));
});
