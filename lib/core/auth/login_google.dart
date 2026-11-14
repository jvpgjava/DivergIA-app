import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../network/api_config.dart';

class LoginGoogleIndisponivel implements Exception {
  const LoginGoogleIndisponivel();
}

// Abstração sobre o SDK do Google: a tela e o controller não dependem do pacote,
// e os testes trocam por um falso.
abstract interface class LoginGoogle {
  /// ID token assinado pelo Google, ou `null` se a pessoa cancelou a escolha de conta.
  Future<String?> obterIdToken();
}

class LoginGoogleNativo implements LoginGoogle {
  LoginGoogleNativo(this._serverClientId);

  final String _serverClientId;
  Future<void>? _inicializacao;

  @override
  Future<String?> obterIdToken() async {
    if (_serverClientId.isEmpty) throw const LoginGoogleIndisponivel();
    final google = GoogleSignIn.instance;
    _inicializacao ??= google.initialize(serverClientId: _serverClientId);
    await _inicializacao;
    try {
      final conta = await google.authenticate();
      return conta.authentication.idToken;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) return null;
      rethrow;
    }
  }
}

final loginGoogleProvider = Provider<LoginGoogle>(
  (ref) => LoginGoogleNativo(ApiConfig.googleServerClientId),
);
