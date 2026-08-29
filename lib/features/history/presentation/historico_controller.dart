import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../data/historico_api.dart';
import '../data/models/analise_resumo.dart';

const _tamanhoPagina = 10;

class HistoricoState {
  const HistoricoState({
    this.loading = true,
    this.errorMessage,
    this.itens = const [],
    this.busca = '',
    this.quantidadeVisivel = _tamanhoPagina,
  });

  final bool loading;
  final String? errorMessage;
  final List<AnaliseResumo> itens;
  final String busca;
  final int quantidadeVisivel;

  List<AnaliseResumo> get itensFiltrados {
    if (busca.trim().isEmpty) return itens;
    final termo = busca.trim().toLowerCase();
    return itens
        .where(
          (item) => (item.textoPreview ?? '').toLowerCase().contains(termo),
        )
        .toList();
  }

  List<AnaliseResumo> get itensPaginados =>
      itensFiltrados.take(quantidadeVisivel).toList();

  bool get temMaisParaCarregar => quantidadeVisivel < itensFiltrados.length;

  HistoricoState copyWith({
    bool? loading,
    String? errorMessage,
    List<AnaliseResumo>? itens,
    String? busca,
    int? quantidadeVisivel,
  }) => HistoricoState(
    loading: loading ?? this.loading,
    errorMessage: errorMessage,
    itens: itens ?? this.itens,
    busca: busca ?? this.busca,
    quantidadeVisivel: quantidadeVisivel ?? this.quantidadeVisivel,
  );
}

class HistoricoController extends StateNotifier<HistoricoState> {
  HistoricoController(this._api) : super(const HistoricoState()) {
    carregar();
  }

  final HistoricoApi _api;

  Future<void> carregar() async {
    state = state.copyWith(loading: true, errorMessage: null);
    try {
      final itens = await _api.listar();
      state = state.copyWith(
        loading: false,
        itens: itens,
        quantidadeVisivel: _tamanhoPagina,
      );
    } on ApiException catch (e) {
      state = state.copyWith(loading: false, errorMessage: e.message);
    }
  }

  void buscar(String termo) {
    state = state.copyWith(busca: termo, quantidadeVisivel: _tamanhoPagina);
  }

  void carregarMais() {
    if (!state.temMaisParaCarregar) return;
    state = state.copyWith(
      quantidadeVisivel: state.quantidadeVisivel + _tamanhoPagina,
    );
  }
}

final historicoControllerProvider =
    StateNotifierProvider.autoDispose<HistoricoController, HistoricoState>((
      ref,
    ) {
      return HistoricoController(ref.watch(historicoApiProvider));
    });
