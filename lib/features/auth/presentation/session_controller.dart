import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/secure_token_storage.dart';

enum SessionStatus { checking, authenticated, unauthenticated }

/// Fonte única da verdade sobre "há sessão válida?" — usada tanto pela
/// splash (decidir a rota inicial) quanto pelo `redirect` do go_router
/// (proteger rotas autenticadas). É um [ChangeNotifier] de propósito: o
/// go_router aceita qualquer [Listenable] como `refreshListenable`.
class SessionController extends ChangeNotifier {
  SessionController(
    this._tokenStorage, {
    this.duracaoMinimaSplash = const Duration(milliseconds: 1100),
  }) {
    checkSession();
  }

  final SecureTokenStorage _tokenStorage;

  /// A leitura do storage local é quase instantânea, então sem isso a
  /// splash (marca + loading) mal chegava a aparecer na tela antes do
  /// `redirect` do go_router já mandar pra login/histórico. A leitura real
  /// já começa a rodar antes dessa espera mínima (não depois), então o
  /// tempo total é o maior dos dois — não a soma.
  final Duration duracaoMinimaSplash;

  SessionStatus status = SessionStatus.checking;

  Future<void> checkSession() async {
    final sessaoValidaFuturo = _lerSessaoValida();
    // `Duration.zero` pula o `Future.delayed` inteiro (em vez de só chamá-lo
    // com zero) de propósito: mesmo um Timer de duração zero é um Timer de
    // verdade, e testes que não dão `pumpAndSettle` depois (só um `pump()`
    // solto) podem terminar com ele ainda "pendente" pro binding de teste.
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
