import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../data/historico_api.dart';
import '../data/models/analise_resumo.dart';

const _tamanhoPagina = 10;

/// `null` = sem ordenação especial (mais recente primeiro, ordem do
/// backend); as demais reordenam a lista já carregada no app.
enum OrdenacaoHistorico { recentes, maiorIntensidade, menorIntensidade }

class HistoricoState {
  const HistoricoState({
    this.loading = true,
    this.errorMessage,
    this.itens = const [],
    this.busca = '',
    this.filtroTipo,
    this.ordenacao = OrdenacaoHistorico.recentes,
    this.quantidadeVisivel = _tamanhoPagina,
  });

  final bool loading;
  final String? errorMessage;
  final List<AnaliseResumo> itens;
  final String busca;

  /// `null` = "Todos"; caso contrário, um dos valores de `tipoDesvioPrincipal`
  /// vindos do backend ("SENTIDO", "POSICAO", "INTENSIDADE").
  final String? filtroTipo;
  final OrdenacaoHistorico ordenacao;
  final int quantidadeVisivel;

  bool get temFiltroAtivo => filtroTipo != null;

  List<AnaliseResumo> get itensFiltrados {
    var resultado = itens;

    if (busca.trim().isNotEmpty) {
      final termo = busca.trim().toLowerCase();
      resultado = resultado
          .where(
            (item) => (item.textoPreview ?? '').toLowerCase().contains(termo),
          )
          .toList();
    }

    if (filtroTipo != null) {
      resultado = resultado
          .where((item) => item.tipoDesvioPrincipal == filtroTipo)
          .toList();
    }

    switch (ordenacao) {
      case OrdenacaoHistorico.recentes:
        break;
      case OrdenacaoHistorico.maiorIntensidade:
        resultado = [...resultado]..sort(
          (a, b) => (b.pontuacaoIntensidade ?? -1).compareTo(
            a.pontuacaoIntensidade ?? -1,
          ),
        );
      case OrdenacaoHistorico.menorIntensidade:
        resultado = [...resultado]..sort(
          (a, b) => (a.pontuacaoIntensidade ?? 999).compareTo(
            b.pontuacaoIntensidade ?? 999,
          ),
        );
    }

    return resultado;
  }

  List<AnaliseResumo> get itensPaginados =>
      itensFiltrados.take(quantidadeVisivel).toList();

  bool get temMaisParaCarregar => quantidadeVisivel < itensFiltrados.length;

  HistoricoState copyWith({
    bool? loading,
    String? errorMessage,
    List<AnaliseResumo>? itens,
    String? busca,
    String? Function()? filtroTipo,
    OrdenacaoHistorico? ordenacao,
    int? quantidadeVisivel,
  }) => HistoricoState(
    loading: loading ?? this.loading,
    errorMessage: errorMessage,
    itens: itens ?? this.itens,
    busca: busca ?? this.busca,
    filtroTipo: filtroTipo != null ? filtroTipo() : this.filtroTipo,
    ordenacao: ordenacao ?? this.ordenacao,
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

  void filtrarPorTipo(String? tipo) {
    state = state.copyWith(
      filtroTipo: () => tipo,
      quantidadeVisivel: _tamanhoPagina,
    );
  }

  void ordenarPor(OrdenacaoHistorico ordenacao) {
    state = state.copyWith(
      ordenacao: ordenacao,
      quantidadeVisivel: _tamanhoPagina,
    );
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
