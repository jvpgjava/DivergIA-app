import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../data/analise_api.dart';
import '../data/models/arquivo_selecionado.dart';
import '../data/models/resultado_analise.dart';

class NovaAnaliseState {
  const NovaAnaliseState({
    this.loading = false,
    this.errorMessage,
    this.erroOriginal,
    this.erroEditado,
  });

  final bool loading;

  final String? errorMessage;

  final String? erroOriginal;
  final String? erroEditado;
}

class NovaAnaliseController extends StateNotifier<NovaAnaliseState> {
  NovaAnaliseController(this._api) : super(const NovaAnaliseState());

  final AnaliseApi _api;

  Future<ResultadoAnalise?> analisar({
    String? textoOriginal,
    ArquivoSelecionado? arquivoOriginal,
    String? textoEditado,
    ArquivoSelecionado? arquivoEditado,
  }) async {
    state = const NovaAnaliseState(loading: true);
    try {
      final resultado = await _api.analisar(
        textoOriginal: textoOriginal,
        arquivoOriginal: arquivoOriginal,
        textoEditado: textoEditado,
        arquivoEditado: arquivoEditado,
        manterHistorico: true,
      );
      state = const NovaAnaliseState();
      return resultado;
    } on ValidationException catch (e) {
      state = switch (e.campo) {
        'ORIGINAL' => NovaAnaliseState(erroOriginal: e.message),
        'EDITADO' => NovaAnaliseState(erroEditado: e.message),
        _ => NovaAnaliseState(errorMessage: e.message),
      };
      return null;
    } on ApiException catch (e) {
      state = NovaAnaliseState(errorMessage: e.message);
      return null;
    }
  }

  void limparErros() {
    if (state.errorMessage != null ||
        state.erroOriginal != null ||
        state.erroEditado != null) {
      state = NovaAnaliseState(loading: state.loading);
    }
  }
}

final novaAnaliseControllerProvider =
    StateNotifierProvider.autoDispose<NovaAnaliseController, NovaAnaliseState>((
      ref,
    ) {
      return NovaAnaliseController(ref.watch(analiseApiProvider));
    });
