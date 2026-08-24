import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/secure_token_storage.dart';

enum SessionStatus { checking, authenticated, unauthenticated }

/// Fonte única da verdade sobre "há sessão válida?" — usada tanto pela
/// splash (decidir a rota inicial) quanto pelo `redirect` do go_router
/// (proteger rotas autenticadas). É um [ChangeNotifier] de propósito: o
/// go_router aceita qualquer [Listenable] como `refreshListenable`.
class SessionController extends ChangeNotifier {
  SessionController(this._tokenStorage) {
    checkSession();
  }

  final SecureTokenStorage _tokenStorage;

  SessionStatus status = SessionStatus.checking;

  Future<void> checkSession() async {
    final token = await _tokenStorage.readAccessToken();
    final expiraEm = await _tokenStorage.readExpiraEm();

    final sessaoValida =
        token != null && expiraEm != null && expiraEm.isAfter(DateTime.now());

    if (!sessaoValida) {
      await _tokenStorage.clear();
    }

    status = sessaoValida
        ? SessionStatus.authenticated
        : SessionStatus.unauthenticated;
    notifyListeners();
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
