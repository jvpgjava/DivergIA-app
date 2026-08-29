import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../data/rewrite_api.dart';

class RewriteState {
  const RewriteState({this.loading = true, this.errorMessage, this.sugestao});

  final bool loading;
  final String? errorMessage;
  final String? sugestao;
}

/// Busca a sugestão de reescrita assim que criado — a tela não tem um
/// gatilho de usuário separado pra isso, ela já abre carregando.
class RewriteController extends StateNotifier<RewriteState> {
  RewriteController(this._api, this._trechoId) : super(const RewriteState()) {
    carregar();
  }

  final RewriteApi _api;
  final String _trechoId;

  Future<void> carregar() async {
    state = const RewriteState(loading: true);
    try {
      final sugestao = await _api.sugerir(_trechoId);
      state = RewriteState(loading: false, sugestao: sugestao);
    } on ApiException catch (e) {
      state = RewriteState(loading: false, errorMessage: e.message);
    }
  }
}

final rewriteControllerProvider = StateNotifierProvider.autoDispose
    .family<RewriteController, RewriteState, String>((ref, trechoId) {
      return RewriteController(ref.watch(rewriteApiProvider), trechoId);
    });
