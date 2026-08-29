import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../data/analise_api.dart';
import '../data/models/arquivo_selecionado.dart';
import '../data/models/resultado_analise.dart';

class NovaAnaliseState {
  const NovaAnaliseState({this.loading = false, this.errorMessage});

  final bool loading;
  final String? errorMessage;
}

class NovaAnaliseController extends StateNotifier<NovaAnaliseState> {
  NovaAnaliseController(this._api) : super(const NovaAnaliseState());

  final AnaliseApi _api;

  /// `manterHistorico` fixo em `true` por enquanto — o toggle de
  /// privacidade de verdade (ligado ao consentimento global) é escopo da
  /// Fase 6 (Perfil). O Figma desta tela também não mostra esse controle.
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
    } on ApiException catch (e) {
      state = NovaAnaliseState(errorMessage: e.message);
      return null;
    }
  }
}

final novaAnaliseControllerProvider =
    StateNotifierProvider.autoDispose<NovaAnaliseController, NovaAnaliseState>((
      ref,
    ) {
      return NovaAnaliseController(ref.watch(analiseApiProvider));
    });
