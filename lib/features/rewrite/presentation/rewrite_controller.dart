import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../data/rewrite_api.dart';

class RewriteState {
  const RewriteState({
    this.loading = true,
    this.errorMessage,
    this.sugestoes = const [],
    this.indiceSelecionado = 0,
    this.aceitando = false,
  });

  final bool loading;
  final String? errorMessage;
  final List<String> sugestoes;
  final int indiceSelecionado;

  /// Enquanto `PUT .../sugestao-reescrita` está em voo — trava o botão
  /// "Aceitar sugestão" pra evitar duplo toque.
  final bool aceitando;

  RewriteState copyWith({
    bool? loading,
    String? errorMessage,
    List<String>? sugestoes,
    int? indiceSelecionado,
    bool? aceitando,
  }) => RewriteState(
    loading: loading ?? this.loading,
    errorMessage: errorMessage,
    sugestoes: sugestoes ?? this.sugestoes,
    indiceSelecionado: indiceSelecionado ?? this.indiceSelecionado,
    aceitando: aceitando ?? this.aceitando,
  );
}

/// Busca 3 sugestões de reescrita assim que criado — a tela não tem um
/// gatilho de usuário separado pra isso, ela já abre carregando. Também
/// permite gerar uma nova rodada de 3 (quando o usuário descarta e pede
/// mais opções) e aceitar a sugestão selecionada.
class RewriteController extends StateNotifier<RewriteState> {
  RewriteController(this._api, this._trechoId) : super(const RewriteState()) {
    carregar();
  }

  final RewriteApi _api;
  final String _trechoId;

  Future<void> carregar() async {
    state = const RewriteState(loading: true);
    try {
      final sugestoes = await _api.sugerir(_trechoId);
      state = RewriteState(loading: false, sugestoes: sugestoes);
    } on ApiException catch (e) {
      state = RewriteState(loading: false, errorMessage: e.message);
    }
  }

  void selecionar(int indice) {
    state = state.copyWith(indiceSelecionado: indice);
  }

  Future<bool> aceitar() async {
    if (state.sugestoes.isEmpty) return false;
    state = state.copyWith(aceitando: true);
    try {
      await _api.aceitar(_trechoId, state.sugestoes[state.indiceSelecionado]);
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(aceitando: false, errorMessage: e.message);
      return false;
    }
  }
}

final rewriteControllerProvider = StateNotifierProvider.autoDispose
    .family<RewriteController, RewriteState, String>((ref, trechoId) {
      return RewriteController(ref.watch(rewriteApiProvider), trechoId);
    });
