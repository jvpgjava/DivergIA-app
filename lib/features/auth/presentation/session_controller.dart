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
    final token = await _tokenStorage.readAccessToken();
    final expiraEm = await _tokenStorage.readExpiraEm();

    final sessaoValida =
        token != null && expiraEm != null && expiraEm.isAfter(DateTime.now());

    if (!sessaoValida) {
      await _tokenStorage.clear();
    }

    return sessaoValida;
  }

  Future<void> onLoginSuccess({
    required String accessToken,
    required DateTime expiraEm,
  }) async {
    await _tokenStorage.saveSession(
      accessToken: accessToken,
      expiraEm: expiraEm,
    );
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
